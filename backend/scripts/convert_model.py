#!/usr/bin/env python3
"""
Model conversion utilities for ClimbingCrux.

Supports exporting YOLOv9 models to various formats:
- ONNX (cross-platform)
- CoreML (iOS/macOS)
- TensorRT (NVIDIA GPUs)
- TFLite (Android/Edge devices)

Requirements:
    pip install ultralytics coremltools torch onnx

Usage:
    python convert_model.py --model path/to/model.pt --format onnx
    python convert_model.py --model path/to/model.pt --format coreml
"""

import argparse
import os
import sys


def convert_model(model_path: str, output_format: str, output_path: str = None, img_size: int = 1216):
    """
    Convert YOLO model to specified format.
    
    Args:
        model_path: Path to the trained .pt model file
        output_format: Target format (onnx, coreml, tflite, tensorrt)
        output_path: Optional output path
        img_size: Input image size (default: 1216 to match training)
    """
    try:
        from ultralytics import YOLO
    except ImportError:
        print("Error: ultralytics not installed. Run: pip install ultralytics")
        sys.exit(1)
    
    print(f"Loading model from: {model_path}")
    model = YOLO(model_path)
    
    print(f"Converting to {output_format.upper()} format...")
    print(f"  Input size: {img_size}x{img_size}")
    
    # Export to specified format
    export_args = {
        'format': output_format,
        'imgsz': img_size,
    }
    
    # Format-specific options
    if output_format == 'coreml':
        export_args['nms'] = True  # Include NMS in model
    elif output_format == 'onnx':
        export_args['simplify'] = True
        export_args['dynamic'] = False
    elif output_format == 'tflite':
        export_args['int8'] = False  # Set True for quantization
    
    result = model.export(**export_args)
    
    print(f"\nConversion complete!")
    print(f"Output: {result}")
    
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Convert YOLOv9 model to various deployment formats"
    )
    parser.add_argument(
        "--model", "-m",
        type=str,
        required=True,
        help="Path to the trained YOLO model (.pt file)"
    )
    parser.add_argument(
        "--format", "-f",
        type=str,
        default="onnx",
        choices=['onnx', 'coreml', 'tflite', 'tensorrt', 'openvino'],
        help="Output format (default: onnx)"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        default=None,
        help="Output path (optional, uses default naming if not specified)"
    )
    parser.add_argument(
        "--size", "-s",
        type=int,
        default=1216,
        help="Input image size (default: 1216)"
    )
    
    args = parser.parse_args()
    
    # Validate input
    if not os.path.exists(args.model):
        print(f"Error: Model file not found: {args.model}")
        sys.exit(1)
    
    convert_model(args.model, args.format, args.output, args.size)


if __name__ == "__main__":
    main()
