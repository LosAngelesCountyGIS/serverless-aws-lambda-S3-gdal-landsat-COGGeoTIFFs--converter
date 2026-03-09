#!/bin/bash
# PURPOSE: Reproject RGB bands to California State Plane (EPSG:2229)
# EPSG:2229 is optimized for Southern California measurements in feet

echo "=========================================="
echo "STEP 2: REPROJECTING RGB BANDS"
echo "=========================================="

BASE_DIR="/home/professor/Downloads/landsat_to_cog"
INPUT_DIR="$BASE_DIR/original_data"
OUTPUT_DIR="$BASE_DIR/processing_pipeline/02_reprojected"
TARGET_CRS="EPSG:2229"

echo "Target CRS: $TARGET_CRS (California State Plane Zone 5)"

# Find band files
BLUE_BAND=$(ls $INPUT_DIR/*SR_B2.TIF | head -1)
GREEN_BAND=$(ls $INPUT_DIR/*SR_B3.TIF | head -1)
RED_BAND=$(ls $INPUT_DIR/*SR_B4.TIF | head -1)

echo "Found Blue band: $(basename $BLUE_BAND)"
echo "Found Green band: $(basename $GREEN_BAND)"
echo "Found Red band: $(basename $RED_BAND)"

# Reproject each band
echo "Reprojecting Blue band..."
gdalwarp -t_srs $TARGET_CRS -r bilinear -multi -overwrite \
    "$BLUE_BAND" "$OUTPUT_DIR/reprojected_B2_blue.tif"

echo "Reprojecting Green band..."
gdalwarp -t_srs $TARGET_CRS -r bilinear -multi -overwrite \
    "$GREEN_BAND" "$OUTPUT_DIR/reprojected_B3_green.tif"

echo "Reprojecting Red band..."
gdalwarp -t_srs $TARGET_CRS -r bilinear -multi -overwrite \
    "$RED_BAND" "$OUTPUT_DIR/reprojected_B4_red.tif"

echo "✅ STEP 2 COMPLETE"
ls -la $OUTPUT_DIR/
