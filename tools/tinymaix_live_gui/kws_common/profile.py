from dataclasses import dataclass


@dataclass(frozen=True)
class KwsFeatureProfile:
    sample_rate: int = 16000
    sample_count: int = 32768
    frame_length: int = 512
    frame_step: int = 512
    frame_count: int = 64
    mel_bins: int = 40
    nfft: int = 512
    pre_emphasis: float = 0.97
    voice_margin_samples: int = 1024


KWS_PROFILE = KwsFeatureProfile()
