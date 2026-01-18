# ClimbingCrux - Climbing Route Generation Backend

A machine learning backend for detecting climbing holds and generating personalized climbing routes using computer vision and biometric-aware pathfinding.

## Overview

This backend system:
1. **Detects climbing holds** from images using YOLOv9 object detection
2. **Calibrates real-world distances** using ArUco markers
3. **Generates optimal routes** using A* pathfinding with biometric cost functions
4. **Suggests limb placement** (left/right hand/foot) for each move

## Features

- **YOLOv9 Hold Detection**: Detects climbing holds and volumes from wall images
- **ArUco Marker Calibration**: Converts pixel distances to real-world centimeters
- **Biometric Cost Function**: Penalizes moves that exceed user's wingspan/reach
- **A* Pathfinding**: Finds optimal routes from start to finish holds
- **Limb Assignment**: Suggests which hand/foot to use for each hold

## Project Structure

```
ClimbingCrux/
├── src/
│   ├── __init__.py
│   ├── config.py              # Configuration settings
│   ├── aruco_marker.py        # ArUco detection and calibration
│   ├── objects_detector.py    # YOLO hold detection
│   ├── route_generator.py     # A* pathfinding engine
│   ├── image_utils.py         # Image processing utilities
│   └── model/
│       ├── __init__.py
│       ├── body_proportion.py # Biometric calculations
│       ├── climber.py         # Climber state model
│       ├── detected_object.py # Detection result model
│       ├── point.py           # Point geometry
│       └── color.py           # Color utilities
├── api/
│   └── main.py                # FastAPI endpoints
├── scripts/
│   └── convert_model.py       # Model conversion utilities
├── model/                     # Trained model weights (not in git)
├── resources/
│   └── aruco_marker_5x5.png   # Calibration marker
├── tests/
│   └── test_*.py              # Unit tests
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Installation

### Prerequisites
- Python 3.11+
- Poetry or pip

### Setup

```bash
# Clone repository
git clone https://github.com/raiyan37/rock-climber.git
cd rock-climber/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Or with Poetry
poetry install
```

### Download Model

Download the trained YOLOv9 model and place in `model/` directory:
- [Download Model](https://drive.google.com/file/d/1n2eCwIOLOGnisuqwGP7IY1-T6J1YNScu/view?usp=sharing)

## Usage

### API Server

```bash
# Start FastAPI server
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# API Documentation
open http://localhost:8000/docs
```

### API Endpoints

#### Health
```bash
GET /health
# Response: {"message":"ok"}
```

#### Generate Route
```bash
POST /boulder/generate
Content-Type: multipart/form-data

# Request: Upload image file
# Response: PNG image with route overlay
```

#### Example with curl
```bash
curl -X POST "http://localhost:8000/boulder/generate" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@climbing_wall.jpg" \
  --output route.png
```

### Docker

```bash
# Build and run with Docker
docker-compose up -d --build

# Access API
curl http://localhost:8000/docs
```

### Tests

```bash
pytest
```

## Configuration

Edit `src/config.py` to customize:

```python
# Climber biometrics
CLIMBER_HEIGHT_IN_CM = 170
STEP_RADIUS_IN_CM = 70
STARTING_STEPS_MAX_DISTANCE_FROM_GROUND_IN_CM = 40

# ArUco marker
MARKER_PERIMETER_IN_CM = 28  # 4 * 7cm sides
MARKER_ARUCO_DICT = cv2.aruco.DICT_5X5_50

# Model settings
YOLO_MODEL_PATH = "model/best.pt"
YOLO_DEVICE = "cpu"  # or "cuda" for GPU
```

## Algorithm Details

### Cost Function

The biometric-aware cost function uses soft constraints:

```
Cost = BaseDistance × BiometricFactor

BiometricFactor = 
  - 1.0 if distance ≤ reach radius
  - 2^((overshoot/reach) × 3) if distance > reach radius
```

This allows "impossible" moves to remain in the solution space with high cost, enabling dynamic moves (dynos) when necessary.

### Limb Assignment

Limbs are assigned based on:
1. **Vertical position**: Hands above hips, feet below
2. **Horizontal position**: Left side → left limb, right side → right limb
3. **Alternating pattern**: Encourages efficient climbing rhythm

## Model Training

To train your own model:

1. **Prepare dataset** with YOLO format annotations
2. **Configure** `config.yaml`:
   ```yaml
   train: datasets/images/train
   val: datasets/images/val
   names:
     0: hold
     1: volume
   ```
3. **Train**:
   ```bash
   yolo train model=yolov9c.pt data=config.yaml epochs=100 imgsz=1216
   ```

## Performance

- **mAP50-95**: 0.8216 (82.16%)
- **mAP50**: 0.9298 (92.98%)
- **mAP75**: 0.8925 (89.25%)

## License

MIT License - See [LICENSE](LICENSE) for details.

Based on [climbingcrux_model](https://github.com/mkurc1/climbingcrux_model) by Michał Kurcewicz.

## Credits

- Original Python implementation: Michał Kurcewicz
- Backend adaptation: Raiyan Haque
