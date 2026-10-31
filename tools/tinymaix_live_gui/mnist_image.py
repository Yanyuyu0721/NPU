from PIL import Image, ImageChops, ImageOps

try:
    RESAMPLE_LANCZOS = Image.Resampling.LANCZOS
except AttributeError:
    RESAMPLE_LANCZOS = Image.LANCZOS


def preprocess_mnist(image: Image.Image, invert: bool = True, threshold: int = 20) -> Image.Image:
    gray = image.convert("L")
    if invert:
        gray = ImageOps.invert(gray)

    bbox = _foreground_bbox(gray, threshold)
    if bbox is None:
        return Image.new("L", (28, 28), 0)

    digit = gray.crop(bbox)
    digit = ImageOps.autocontrast(digit)
    digit.thumbnail((20, 20), RESAMPLE_LANCZOS)

    out = Image.new("L", (28, 28), 0)
    left = (28 - digit.width) // 2
    top = (28 - digit.height) // 2
    out.paste(digit, (left, top))
    return out


def image_to_payload(image: Image.Image) -> bytes:
    if image.mode != "L" or image.size != (28, 28):
        raise ValueError("payload image must be 28x28 grayscale")
    return image.tobytes()


def _foreground_bbox(gray: Image.Image, threshold: int):
    mask = gray.point(lambda p: 255 if p > threshold else 0)
    empty = Image.new("L", gray.size, 0)
    return ImageChops.difference(mask, empty).getbbox()
