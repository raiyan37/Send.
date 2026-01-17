import pytest
import cv2
import numpy as np

from src.aruco_marker import ArucoMarker
from src import config


def _generate_marker_bgr(side_px: int = 200, marker_id: int = 0, border_bits: int = 1) -> np.ndarray:
    dictionary = cv2.aruco.getPredefinedDictionary(config.MARKER_ARUCO_DICT)

    if hasattr(cv2.aruco, "generateImageMarker"):
        marker = cv2.aruco.generateImageMarker(dictionary, marker_id, side_px, borderBits=border_bits)
    else:
        marker = np.zeros((side_px, side_px), dtype=np.uint8)
        cv2.aruco.drawMarker(dictionary, marker_id, side_px, marker, borderBits=border_bits)

    return cv2.cvtColor(marker, cv2.COLOR_GRAY2BGR)


def _canvas_with_marker(marker_bgr: np.ndarray, *, width: int = 1216, height: int = 800,
                        x: int = 100, y: int = 100) -> np.ndarray:
    canvas = np.full((height, width, 3), 255, dtype=np.uint8)

    marker_h, marker_w = marker_bgr.shape[:2]
    canvas[y:y + marker_h, x:x + marker_w] = marker_bgr

    return canvas


def test_detect_marker() -> None:
    # given
    img = _canvas_with_marker(_generate_marker_bgr())

    # when
    ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)

    # then
    assert True


def test_detect_marker_when_marker_touches_image_edge() -> None:
    # given
    img = _canvas_with_marker(_generate_marker_bgr(), x=0, y=0)

    # when
    marker = ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)

    # then
    assert marker.marker_id == 0


def test_exception_when_no_marker_detected() -> None:
    # given
    img = np.full((800, 1216, 3), 255, dtype=np.uint8)

    # when and then
    with pytest.raises(ValueError):
        ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)


def test_get_width_in_cm() -> None:
    # given
    img = _canvas_with_marker(_generate_marker_bgr())
    aruco_marker = ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)

    # when
    width_in_cm = aruco_marker.get_width_in_cm()

    # then
    assert round(width_in_cm) == 7


def test_get_height_in_cm() -> None:
    # given
    img = _canvas_with_marker(_generate_marker_bgr())
    aruco_marker = ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)

    # when
    height_in_cm = aruco_marker.get_height_in_cm()

    # then
    assert round(height_in_cm) == 7


def test_convert_cm_to_px_round_trip() -> None:
    # given
    img = _canvas_with_marker(_generate_marker_bgr())
    aruco_marker = ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)

    # when
    cm = 50.0
    px = aruco_marker.convert_cm_to_px(cm)
    cm_round_trip = aruco_marker.convert_px_to_cm(px)

    # then
    assert cm_round_trip == pytest.approx(cm, abs=1.0)
