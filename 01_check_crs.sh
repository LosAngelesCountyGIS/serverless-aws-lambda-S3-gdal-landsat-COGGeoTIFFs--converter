#!/bin/bash
# PURPOSE: Check Coordinate Reference System of all Landsat files
# This ensures all bands have the same projection before processing

echo "=========================================="
echo "STEP 1: CRS ANALYSIS"
echo "=========================================="

BASE_DIR="/home/professor/Downloads/landsat_to_cog"
DATA_DIR="$BASE_DIR/original_data"
REPORT_DIR="$BASE_DIR/processing_pipeline/01_crs_report"

echo "📂 Looking for files in: $DATA_DIR"

# Create report file
REPORT_FILE="$REPORT_DIR/crs_report_$(date +%Y%m%d_%H%M%S).txt"

echo "LANDSAT CRS REPORT" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "=================" >> $REPORT_FILE

# Process each TIFF file
for tif_file in $DATA_DIR/*.TIF; do
    if [ -f "$tif_file" ]; then
        filename=$(basename "$tif_file")
        echo "Processing: $filename"
        
        echo "FILE: $filename" >> $REPORT_FILE
        
        # Get EPSG code
        epsg=$(gdalsrsinfo -o epsg "$tif_file" 2>/dev/null)
        echo "EPSG: $epsg" >> $REPORT_FILE
        
        # Get projection name
        proj=$(gdalsrsinfo "$tif_file" | grep "PROJCS" | head -1)
        echo "Projection: $proj" >> $REPORT_FILE
        
        echo "---" >> $REPORT_FILE
    fi
done

echo "✅ Report saved to: $REPORT_FILE"
echo "STEP 1 COMPLETE"
