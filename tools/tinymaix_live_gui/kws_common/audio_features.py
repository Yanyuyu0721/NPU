import numpy as np

from .profile import KWS_PROFILE


def _as_pcm_f64(samples):
    signal = np.asarray(samples)
    if signal.ndim > 1:
        signal = signal.mean(axis=1)
    signal = signal.astype(np.float64, copy=False).reshape(-1)
    if signal.size and np.max(np.abs(signal)) <= 1.5:
        signal = np.clip(signal, -1.0, 1.0) * 32768.0
    return signal


def _resample_linear(signal, source_rate, target_rate):
    if source_rate <= 0:
        raise ValueError(f"Invalid sample rate: {source_rate}")
    if signal.size == 0 or source_rate == target_rate:
        return signal.astype(np.float64, copy=True)
    target_length = max(1, int(round(signal.size * target_rate / source_rate)))
    source_positions = np.arange(signal.size, dtype=np.float64)
    target_positions = np.arange(target_length, dtype=np.float64) * source_rate / target_rate
    return np.interp(target_positions, source_positions, signal).astype(np.float64)


def _center_fit(signal, target_length):
    if signal.size >= target_length:
        start = (signal.size - target_length) // 2
        return signal[start : start + target_length].copy()
    out = np.zeros(target_length, dtype=np.float64)
    start = (target_length - signal.size) // 2
    out[start : start + signal.size] = signal
    return out


def _voice_bounds(signal):
    if signal.size == 0:
        return None
    frame_length = KWS_PROFILE.frame_length
    frame_count = int(np.ceil(signal.size / frame_length))
    padded = np.pad(signal, (0, frame_count * frame_length - signal.size))
    frames = padded.reshape(frame_count, frame_length)
    energies = np.mean(frames * frames, axis=1)
    peak_energy = float(np.max(energies))
    if not np.isfinite(peak_energy) or peak_energy <= 0.0:
        return None

    noise_floor = float(np.percentile(energies, 20.0))
    threshold = max(noise_floor * 4.0, peak_energy * 0.08, 1.0)
    active = np.flatnonzero(energies >= threshold)
    if active.size == 0:
        return None

    coarse_start = max(0, int(active[0] * frame_length) - frame_length)
    coarse_end = min(signal.size, int((active[-1] + 1) * frame_length) + frame_length)
    coarse = np.abs(signal[coarse_start:coarse_end])
    peak_amplitude = float(np.max(coarse)) if coarse.size else 0.0
    if peak_amplitude <= 0.0:
        return None
    amplitude_threshold = max(peak_amplitude * 0.02, np.sqrt(max(noise_floor, 0.0)) * 3.0, 1.0)
    voiced = np.flatnonzero(coarse >= amplitude_threshold)
    if voiced.size == 0:
        return coarse_start, coarse_end
    return coarse_start + int(voiced[0]), coarse_start + int(voiced[-1]) + 1


def _extract_with_padding(signal, start, end):
    length = max(0, end - start)
    out = np.zeros(length, dtype=np.float64)
    source_start = max(0, start)
    source_end = min(signal.size, end)
    if source_end > source_start:
        out[source_start - start : source_end - start] = signal[source_start:source_end]
    return out


def prepare_kws_audio(samples, sample_rate):
    """Return training-contract PCM: mono, 16 kHz, voice-centered, 32768 samples."""
    signal = _as_pcm_f64(samples)
    signal = _resample_linear(signal, int(sample_rate), KWS_PROFILE.sample_rate)
    if signal.size == 0:
        return np.zeros(KWS_PROFILE.sample_count, dtype=np.float64)

    bounds = _voice_bounds(signal)
    if bounds is None:
        return _center_fit(signal, KWS_PROFILE.sample_count)

    start, end = bounds
    margin = KWS_PROFILE.voice_margin_samples
    segment = _extract_with_padding(signal, start - margin, end + margin)
    return _center_fit(segment, KWS_PROFILE.sample_count)


def _mel_filter_bank():
    n = KWS_PROFILE.mel_bins
    nfft = KWS_PROFILE.nfft
    sample_rate = KWS_PROFILE.sample_rate
    high_freq_mel = 2595.0 * np.log10(1.0 + (sample_rate / 2.0) / 700.0)
    mel_points = np.linspace(0.0, high_freq_mel, n + 2)
    hz_points = 700.0 * (10.0 ** (mel_points / 2595.0) - 1.0)
    bins = (hz_points / (sample_rate / 2.0)) * (nfft / 2.0)
    bank = np.zeros((n, nfft // 2 + 1), dtype=np.float64)
    for i in range(1, n + 1):
        left = int(bins[i - 1])
        center = int(bins[i])
        right = int(bins[i + 1])
        for j in range(left, center):
            bank[i - 1, j + 1] = (j + 1 - bins[i - 1]) / (bins[i] - bins[i - 1])
        for j in range(center, right):
            bank[i - 1, j + 1] = (bins[i + 1] - (j + 1)) / (bins[i + 1] - bins[i])
    return bank


_MEL_FILTER_BANK = _mel_filter_bank()


def compute_kws_fbank(prepared_samples):
    signal = np.asarray(prepared_samples, dtype=np.float64).reshape(-1)
    if signal.size != KWS_PROFILE.sample_count:
        raise ValueError(
            f"KWS FBank expects {KWS_PROFILE.sample_count} prepared samples, got {signal.size}"
        )
    frames = signal.reshape(KWS_PROFILE.frame_count, KWS_PROFILE.frame_length).copy()
    frames[:, 1:] -= KWS_PROFILE.pre_emphasis * frames[:, :-1]
    magnitude = np.abs(np.fft.rfft(frames, KWS_PROFILE.nfft))
    power = magnitude * magnitude
    banks = np.dot(power, _MEL_FILTER_BANK.T)
    banks = np.maximum(banks, np.finfo(np.float64).eps)
    banks = np.maximum(np.log(banks) - 3.0, 0.0) * 10.0
    return np.clip(banks, 0.0, 255.0).astype(np.uint8)


def make_kws_fbank(samples, sample_rate):
    return compute_kws_fbank(prepare_kws_audio(samples, sample_rate))
