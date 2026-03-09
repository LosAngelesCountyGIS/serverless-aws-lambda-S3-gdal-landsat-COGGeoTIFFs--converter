#!/bin/bash
# PURPOSE: Merge individual bands into a single RGB image
# Creates a true-color image that humans can interpret

echo "=========================================="
echo "STEP 3: MERGING RGB BANDS"
echo "=========================================="

BASE_DIR="/home/professor/Downloads/landsat_to_cog"
INPUT_DIR="$BASE_DIR/processing_pipeline/02_reprojected"
OUTPUT_DIR="$BASE_DIR/processing_pipeline/03_rgb_merged"
OUTPUT_FILE="$OUTPUT_DIR/rgb_merged_$(date +%Y%m%d).tif"

echo "Merging Red, Green, and Blue bands..."

# Merge bands (order: Red, Green, Blue)
gdal_merge.py -separate -of GTiff -o "$OUTPUT_FILE" \
    "$INPUT_DIR/reprojected_B4_red.tif" \
    "$INPUT_DIR/reprojected_B3_green.tif" \
    "$INPUT_DIR/reprojected_B2_blue.tif"

# Set color interpretation
gdal_edit.py -colorinterp_1 red "$OUTPUT_FILE"
gdal_edit.py -colorinterp_2 green "$OUTPUT_FILE"
gdal_edit.py -colorinterp_3 blue "$OUTPUT_FILE"

echo "✅ STEP 3 COMPLETE - File: $OUTPUT_FILE"
