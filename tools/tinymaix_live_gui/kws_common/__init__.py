"""Shared KWS audio preprocessing used by desktop and web frontends."""

from .audio_features import compute_kws_fbank, make_kws_fbank, prepare_kws_audio
from .profile import KWS_PROFILE

__all__ = ["KWS_PROFILE", "compute_kws_fbank", "make_kws_fbank", "prepare_kws_audio"]
