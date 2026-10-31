"""Optional Windows pen/digitizer support for the Tk MNIST console.

USB drawing tablets normally appear to Tk as a mouse, so the existing canvas
already accepts them.  This module adds two Windows-only improvements on top:

* enumerate pen/digitizer devices for the GUI status line;
* receive WM_POINTER messages from the canvas so pen pressure is available.

The module stays importable on non-Windows machines.  In that case
``list_tablet_devices`` returns an empty list and ``PenInputAdapter`` reports
``supported == False``.
"""

from __future__ import annotations

import ctypes
import re
import sys
from collections import deque
from dataclasses import dataclass
from typing import Callable, Deque, List, Sequence, Tuple

IS_WINDOWS = sys.platform == "win32"

WM_POINTERUPDATE = 0x0245
WM_POINTERDOWN = 0x0246
WM_POINTERUP = 0x0247
WM_POINTERCAPTURECHANGED = 0x024C

PT_PEN = 0x00000003

POINTER_FLAG_INCONTACT = 0x00000004
POINTER_FLAG_CANCELED = 0x00000800

PEN_MASK_PRESSURE = 0x00000001

GWLP_WNDPROC = -4
RIDI_DEVICEINFO = 0x2000000B
RIDI_DEVICENAME = 0x20000007
RIM_TYPEHID = 2
DIGITIZER_USAGE_PAGE = 0x0D
PEN_USAGES = {0x01, 0x02, 0x03, 0x06, 0x08, 0x0C}

MAX_PRESSURE = 1024.0


@dataclass(frozen=True)
class TabletDevice:
    """A pen/touch/HID digitizer reported by Windows."""

    name: str
    kind: str  # "pen", "touch" or "hid"
    detail: str = ""
    pressure_capable: bool = False


@dataclass(frozen=True)
class PenEvent:
    """One pen sample in canvas coordinates."""

    x: float
    y: float
    pressure: int = 0
    pressure_supported: bool = False


def pressure_to_width(
    pressure: int,
    pressure_supported: bool,
    enabled: bool = True,
    default_width: int = 18,
    min_width: int = 7,
    max_width: int = 26,
) -> int:
    """Map Windows' 0..1024 pen pressure to a visible stroke width."""

    if not enabled or not pressure_supported:
        return default_width
    try:
        ratio = float(pressure) / MAX_PRESSURE
    except (TypeError, ValueError):
        return default_width
    ratio = max(0.0, min(1.0, ratio))
    width = int(round(min_width + (max_width - min_width) * ratio))
    return max(min_width, min(max_width, width))


def _device_type_name(device_type: int) -> Tuple[str, str]:
    if device_type == 0x00000001:
        return "pen", "内置数位笔"
    if device_type == 0x00000002:
        return "pen", "外接数位笔"
    if device_type == 0x00000003:
        return "touch", "触摸屏"
    if device_type == 0x00000004:
        return "touchpad", "触控板"
    return "other", f"指针设备({device_type})"


if IS_WINDOWS:
    from ctypes import wintypes

    _user32 = ctypes.WinDLL("user32", use_last_error=True)

    class _POINT(ctypes.Structure):
        _fields_ = [("x", wintypes.LONG), ("y", wintypes.LONG)]

    class _RECT(ctypes.Structure):
        _fields_ = [
            ("left", wintypes.LONG),
            ("top", wintypes.LONG),
            ("right", wintypes.LONG),
            ("bottom", wintypes.LONG),
        ]

    class _POINTER_INFO(ctypes.Structure):
        _fields_ = [
            ("pointerType", ctypes.c_int),
            ("pointerId", wintypes.UINT),
            ("frameId", wintypes.UINT),
            ("pointerFlags", ctypes.c_int),
            ("sourceDevice", wintypes.HANDLE),
            ("hwndTarget", wintypes.HWND),
            ("ptPixelLocation", _POINT),
            ("ptHimetricLocation", _POINT),
            ("ptPixelLocationRaw", _POINT),
            ("ptHimetricLocationRaw", _POINT),
            ("dwTime", wintypes.DWORD),
            ("historyCount", wintypes.UINT),
            ("InputData", ctypes.c_int32),
            ("dwKeyStates", wintypes.DWORD),
            ("PerformanceCount", ctypes.c_uint64),
            ("ButtonChangeType", ctypes.c_int),
        ]

    class _POINTER_PEN_INFO(ctypes.Structure):
        _fields_ = [
            ("pointerInfo", _POINTER_INFO),
            ("penFlags", ctypes.c_int),
            ("penMask", ctypes.c_int),
            ("pressure", wintypes.UINT),
            ("rotation", wintypes.UINT),
            ("tiltX", ctypes.c_int32),
            ("tiltY", ctypes.c_int32),
        ]

    class _POINTER_TOUCH_INFO(ctypes.Structure):
        _fields_ = [
            ("pointerInfo", _POINTER_INFO),
            ("touchFlags", ctypes.c_int),
            ("touchMask", ctypes.c_int),
            ("rcContact", _RECT),
            ("rcContactRaw", _RECT),
            ("orientation", wintypes.UINT),
            ("pressure", wintypes.UINT),
        ]

    class _POINTER_DEVICE_INFO(ctypes.Structure):
        _fields_ = [
            ("displayOrientation", wintypes.DWORD),
            ("device", wintypes.HANDLE),
            ("pointerDeviceType", ctypes.c_int),
            ("monitor", wintypes.HMONITOR),
            ("startingCursorId", wintypes.ULONG),
            ("maxActiveContacts", wintypes.USHORT),
            ("productString", wintypes.WCHAR * 520),
        ]

    class _RAWINPUTDEVICELIST(ctypes.Structure):
        _fields_ = [("hDevice", wintypes.HANDLE), ("dwType", wintypes.DWORD)]

    class _RID_DEVICE_INFO_MOUSE(ctypes.Structure):
        _fields_ = [
            ("dwId", wintypes.DWORD),
            ("dwNumberOfButtons", wintypes.DWORD),
            ("dwSampleRate", wintypes.DWORD),
            ("fHasHorizontalWheel", wintypes.BOOL),
        ]

    class _RID_DEVICE_INFO_KEYBOARD(ctypes.Structure):
        _fields_ = [
            ("dwType", wintypes.DWORD),
            ("dwSubType", wintypes.DWORD),
            ("dwKeyboardMode", wintypes.DWORD),
            ("dwNumberOfFunctionKeys", wintypes.DWORD),
            ("dwNumberOfIndicators", wintypes.DWORD),
            ("dwNumberOfKeysTotal", wintypes.DWORD),
        ]

    class _RID_DEVICE_INFO_HID(ctypes.Structure):
        _fields_ = [
            ("dwVendorId", wintypes.DWORD),
            ("dwProductId", wintypes.DWORD),
            ("dwVersionNumber", wintypes.DWORD),
            ("usUsagePage", wintypes.USHORT),
            ("usUsage", wintypes.USHORT),
        ]

    class _RID_DEVICE_INFO_UNION(ctypes.Union):
        _fields_ = [
            ("mouse", _RID_DEVICE_INFO_MOUSE),
            ("keyboard", _RID_DEVICE_INFO_KEYBOARD),
            ("hid", _RID_DEVICE_INFO_HID),
        ]

    class _RID_DEVICE_INFO(ctypes.Structure):
        _anonymous_ = ("u",)
        _fields_ = [
            ("cbSize", wintypes.DWORD),
            ("dwType", wintypes.DWORD),
            ("u", _RID_DEVICE_INFO_UNION),
        ]

    _WNDPROC = ctypes.WINFUNCTYPE(
        ctypes.c_ssize_t,
        wintypes.HWND,
        wintypes.UINT,
        wintypes.WPARAM,
        wintypes.LPARAM,
    )

    _user32.GetPointerDevices.argtypes = [
        ctypes.POINTER(wintypes.UINT),
        ctypes.POINTER(_POINTER_DEVICE_INFO),
    ]
    _user32.GetPointerDevices.restype = wintypes.BOOL

    _user32.GetPointerType.argtypes = [wintypes.UINT, ctypes.POINTER(ctypes.c_int)]
    _user32.GetPointerType.restype = wintypes.BOOL

    _user32.GetPointerPenInfo.argtypes = [
        wintypes.UINT,
        ctypes.POINTER(_POINTER_PEN_INFO),
    ]
    _user32.GetPointerPenInfo.restype = wintypes.BOOL

    _user32.GetRawInputDeviceList.argtypes = [
        ctypes.POINTER(_RAWINPUTDEVICELIST),
        ctypes.POINTER(wintypes.UINT),
        wintypes.UINT,
    ]
    _user32.GetRawInputDeviceList.restype = wintypes.UINT

    _user32.GetRawInputDeviceInfoW.argtypes = [
        wintypes.HANDLE,
        wintypes.UINT,
        ctypes.c_void_p,
        ctypes.POINTER(wintypes.UINT),
    ]
    _user32.GetRawInputDeviceInfoW.restype = wintypes.UINT

    _user32.ScreenToClient.argtypes = [wintypes.HWND, ctypes.POINTER(_POINT)]
    _user32.ScreenToClient.restype = wintypes.BOOL

    _user32.GetClientRect.argtypes = [wintypes.HWND, ctypes.POINTER(_RECT)]
    _user32.GetClientRect.restype = wintypes.BOOL

    _set_window_long = (
        _user32.SetWindowLongPtrW
        if ctypes.sizeof(ctypes.c_void_p) == 8
        else _user32.SetWindowLongW
    )
    _set_window_long.argtypes = [wintypes.HWND, ctypes.c_int, ctypes.c_void_p]
    _set_window_long.restype = ctypes.c_void_p

    _user32.CallWindowProcW.argtypes = [
        ctypes.c_void_p,
        wintypes.HWND,
        wintypes.UINT,
        wintypes.WPARAM,
        wintypes.LPARAM,
    ]
    _user32.CallWindowProcW.restype = ctypes.c_ssize_t

    def _pointer_product_name(device: _POINTER_DEVICE_INFO) -> str:
        offset = _POINTER_DEVICE_INFO.productString.offset
        value = ctypes.wstring_at(ctypes.addressof(device) + offset)
        return value.strip()

    def _raw_input_name(hdevice: wintypes.HANDLE) -> str:
        size = wintypes.UINT(0)
        _user32.GetRawInputDeviceInfoW(
            hdevice, RIDI_DEVICENAME, None, ctypes.byref(size)
        )
        if size.value <= 1:
            return ""
        buffer = ctypes.create_unicode_buffer(size.value)
        result = _user32.GetRawInputDeviceInfoW(
            hdevice,
            RIDI_DEVICENAME,
            ctypes.cast(buffer, ctypes.c_void_p),
            ctypes.byref(size),
        )
        return buffer.value if result else ""

    def _raw_hid_devices() -> List[TabletDevice]:
        count = wintypes.UINT(0)
        if not _user32.GetRawInputDeviceList(
            None, ctypes.byref(count), ctypes.sizeof(_RAWINPUTDEVICELIST)
        ):
            return []
        if count.value == 0:
            return []
        listing = (_RAWINPUTDEVICELIST * count.value)()
        actual = _user32.GetRawInputDeviceList(
            listing,
            ctypes.byref(count),
            ctypes.sizeof(_RAWINPUTDEVICELIST),
        )
        if actual in (0, 0xFFFFFFFF):
            return []
        devices: List[TabletDevice] = []
        seen = set()
        for entry in listing[:actual]:
            if entry.dwType != RIM_TYPEHID:
                continue
            info = _RID_DEVICE_INFO()
            info.cbSize = ctypes.sizeof(_RID_DEVICE_INFO)
            size = wintypes.UINT(ctypes.sizeof(_RID_DEVICE_INFO))
            result = _user32.GetRawInputDeviceInfoW(
                entry.hDevice,
                RIDI_DEVICEINFO,
                ctypes.cast(ctypes.byref(info), ctypes.c_void_p),
                ctypes.byref(size),
            )
            if not result:
                continue
            if info.hid.usUsagePage != DIGITIZER_USAGE_PAGE:
                continue
            if info.hid.usUsage not in PEN_USAGES:
                continue
            path = _raw_input_name(entry.hDevice)
            match = re.search(
                r"VID_([0-9A-Fa-f]{4}).*?PID_([0-9A-Fa-f]{4})", path
            )
            detail = (
                f"VID_{match.group(1).upper()} PID_{match.group(2).upper()}"
                if match
                else "HID digitizer"
            )
            key = detail.lower()
            if key in seen:
                continue
            seen.add(key)
            devices.append(
                TabletDevice(
                    name=f"HID 数位板 {detail}",
                    kind="hid",
                    detail=detail,
                    pressure_capable=False,
                )
            )
        return devices

    def list_tablet_devices() -> List[TabletDevice]:
        """Return Windows Ink pen/touch devices plus raw HID digitizers."""

        devices: List[TabletDevice] = []
        seen_pen_names = set()

        count = wintypes.UINT(0)
        if _user32.GetPointerDevices(ctypes.byref(count), None) and count.value:
            listing = (_POINTER_DEVICE_INFO * count.value)()
            if _user32.GetPointerDevices(ctypes.byref(count), listing):
                for entry in listing[: count.value]:
                    kind, type_name = _device_type_name(entry.pointerDeviceType)
                    if kind not in ("pen", "touch"):
                        continue
                    product = _pointer_product_name(entry) or type_name
                    key = product.lower()
                    if key in seen_pen_names:
                        continue
                    seen_pen_names.add(key)
                    devices.append(
                        TabletDevice(
                            name=product,
                            kind=kind,
                            detail=type_name,
                            pressure_capable=(kind == "pen"),
                        )
                    )

        if not any(device.kind == "pen" for device in devices):
            devices.extend(_raw_hid_devices())
        return devices

    class PenInputAdapter:
        """Subclass a Tk widget's HWND and turn WM_POINTER pen input into events.

        Tk 8.6 does not expose pen pressure.  WM_POINTER messages are delivered
        to the canvas before Windows promotes them to mouse messages, so a
        small WndProc shim is enough.  Events are queued and drained from a Tk
        timer to avoid calling Tk from inside a native window procedure.
        """

        def __init__(
            self,
            widget,
            on_down: Callable[[PenEvent], None],
            on_move: Callable[[PenEvent], None],
            on_up: Callable[[PenEvent], None],
        ):
            self.widget = widget
            self._on_down = on_down
            self._on_move = on_move
            self._on_up = on_up
            self._queue: Deque[Tuple[str, float, float, int, bool]] = deque()
            self._hwnd = None
            self._old_proc = None
            self._callback = None
            self._drain_job = None
            self._active_pointer_id = None
            self.supported = False
            self.error = ""

            try:
                self._hwnd = int(widget.winfo_id())
                self._callback = _WNDPROC(self._wndproc)
                self._old_proc = _set_window_long(
                    self._hwnd,
                    GWLP_WNDPROC,
                    ctypes.cast(self._callback, ctypes.c_void_p),
                )
                if not self._old_proc:
                    raise OSError(ctypes.get_last_error(), "SetWindowLongPtrW failed")
                self.supported = True
                self._drain_job = widget.after(8, self._drain)
            except Exception as exc:  # pragma: no cover - depends on host
                self.supported = False
                self.error = str(exc)
                self._old_proc = None

        def close(self):
            if self._drain_job is not None:
                try:
                    self.widget.after_cancel(self._drain_job)
                except Exception:
                    pass
                self._drain_job = None
            if self._hwnd and self._old_proc:
                try:
                    _set_window_long(self._hwnd, GWLP_WNDPROC, self._old_proc)
                except Exception:
                    pass
            self._old_proc = None
            self._callback = None

        def _wndproc(self, hwnd, msg, wparam, lparam):
            if msg in (WM_POINTERDOWN, WM_POINTERUPDATE, WM_POINTERUP):
                try:
                    if self._handle_pointer_message(msg, wparam):
                        return 0
                except Exception:
                    self._cancel_active_pointer()
            elif msg == WM_POINTERCAPTURECHANGED:
                if self._active_pointer_id is not None:
                    self._active_pointer_id = None
                    self._queue.append(("cancel", -1.0, -1.0, 0, False))
            return _user32.CallWindowProcW(
                self._old_proc, hwnd, msg, wparam, lparam
            )

        def _cancel_active_pointer(self):
            if self._active_pointer_id is None:
                return
            self._active_pointer_id = None
            self._queue.append(("cancel", -1.0, -1.0, 0, False))

        def _handle_pointer_message(self, msg: int, wparam: int) -> bool:
            pointer_id = int(wparam) & 0xFFFF
            pointer_type = ctypes.c_int(0)
            if not _user32.GetPointerType(pointer_id, ctypes.byref(pointer_type)):
                if msg == WM_POINTERUP:
                    self._cancel_active_pointer()
                return False
            if pointer_type.value != PT_PEN:
                return False

            pen = _POINTER_PEN_INFO()
            if not _user32.GetPointerPenInfo(pointer_id, ctypes.byref(pen)):
                self._cancel_active_pointer()
                return True

            flags = pen.pointerInfo.pointerFlags
            if flags & POINTER_FLAG_CANCELED:
                self._cancel_active_pointer()
                return True

            if msg == WM_POINTERDOWN:
                self._active_pointer_id = pointer_id
            elif self._active_pointer_id != pointer_id:
                # Ignore a stale move/up from a pointer we did not start.
                if msg == WM_POINTERUP and self._active_pointer_id is not None:
                    self._active_pointer_id = None
                    self._queue.append(("cancel", -1.0, -1.0, 0, False))
                return True

            if msg != WM_POINTERUP and not (flags & POINTER_FLAG_INCONTACT):
                return True

            point = _POINT(
                pen.pointerInfo.ptPixelLocation.x,
                pen.pointerInfo.ptPixelLocation.y,
            )
            if not _user32.ScreenToClient(self._hwnd, ctypes.byref(point)):
                self._cancel_active_pointer()
                return True

            pressure_supported = (
                bool(pen.penMask & PEN_MASK_PRESSURE) and pen.pressure > 0
            )
            phase = "down" if msg == WM_POINTERDOWN else "move"
            if msg == WM_POINTERUP:
                phase = "up"
                self._active_pointer_id = None
            self._queue.append(
                (
                    phase,
                    float(point.x),
                    float(point.y),
                    int(pen.pressure),
                    pressure_supported,
                )
            )
            return True

        def _drain(self):
            self._drain_job = None
            try:
                if not self.widget.winfo_exists():
                    return
                # Drop stale moves if the UI was blocked for a while.
                if len(self._queue) > 256:
                    keep = [item for item in self._queue if item[0] != "move"][-8:]
                    moves = [item for item in self._queue if item[0] == "move"][-64:]
                    self._queue = deque(keep + moves)
                while self._queue:
                    phase, x, y, pressure, supported = self._queue.popleft()
                    event = self._to_widget_event(x, y, pressure, supported)
                    if phase == "down":
                        self._on_down(event)
                    elif phase == "move":
                        self._on_move(event)
                    elif phase == "up":
                        self._on_up(event)
                    else:
                        self._on_up(PenEvent(-1.0, -1.0, 0, False))
            except Exception:
                pass
            finally:
                try:
                    if self.widget.winfo_exists():
                        self._drain_job = self.widget.after(8, self._drain)
                except Exception:
                    self._drain_job = None

        def _to_widget_event(
            self, x: float, y: float, pressure: int, supported: bool
        ) -> PenEvent:
            rect = _RECT()
            _user32.GetClientRect(self._hwnd, ctypes.byref(rect))
            client_w = max(1, rect.right - rect.left)
            client_h = max(1, rect.bottom - rect.top)
            tk_w = max(1, self.widget.winfo_width())
            tk_h = max(1, self.widget.winfo_height())
            tk_x = min(max(0.0, x * tk_w / client_w), float(tk_w - 1))
            tk_y = min(max(0.0, y * tk_h / client_h), float(tk_h - 1))
            return PenEvent(tk_x, tk_y, pressure, supported)

else:  # pragma: no cover - non-Windows host

    def list_tablet_devices() -> List[TabletDevice]:
        return []

    class PenInputAdapter:
        supported = False
        error = "Windows only"

        def __init__(self, *args, **kwargs):
            pass

        def close(self):
            pass


def tablet_status_text(devices: Sequence[TabletDevice]) -> str:
    """Format the device list for the compact status line in the GUI."""

    pens = [device for device in devices if device.kind == "pen"]
    touches = [device for device in devices if device.kind == "touch"]
    hids = [device for device in devices if device.kind == "hid"]

    if pens:
        names = []
        for device in pens:
            if device.name not in names:
                names.append(device.name)
        label = ", ".join(names) or "Windows Ink 数位笔"
        suffix = " · 压感可用" if any(d.pressure_capable for d in pens) else ""
        return f"数位板: {label}{suffix}"
    if touches:
        label = ", ".join(dict.fromkeys(device.name for device in touches))
        return f"数位板: 未检测到笔，检测到触摸设备 {label}"
    if hids:
        label = ", ".join(dict.fromkeys(device.detail or device.name for device in hids))
        return f"数位板: 检测到 HID 设备 {label}（无 Windows Ink 压感）"
    return "数位板: 未检测到（USB 数位板插上后会自动识别）"


def tablet_status_short(devices: Sequence[TabletDevice]) -> str:
    """Very compact status for the single-row toolbar."""

    pens = [device for device in devices if device.kind == "pen"]
    touches = [device for device in devices if device.kind == "touch"]
    hids = [device for device in devices if device.kind == "hid"]
    if pens:
        return "数位板: 已连接"
    if touches:
        return "数位板: 触摸"
    if hids:
        return "数位板: HID 无压感"
    return "数位板: 未检测"
