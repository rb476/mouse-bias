# Identity Corrector GUI

A MATLAB graphical user interface (GUI) for reviewing and correcting animal identity tracking data across video trials. This tool is designed for behavioral neuroscience experiments involving multiple animals in a single recording session.

## Overview

The Identity Corrector GUI allows researchers to:
- Load and navigate through video recordings organized by experimental block and trial
- View tracked animal positions overlaid on video frames
- Correct misidentified animal trajectories in real-time
- Save corrected tracking data back to disk

This tool is particularly useful for validating or correcting the output of automated multi-animal tracking systems (e.g., MOTR) when identity switches or tracking errors occur.

## Files

- **`bias_identityCorrectorGUI.m`** - Main application file containing all GUI callbacks and logic
- **`bias_identityCorrectorGUI.fig`** - MATLAB GUI layout file (created with GUIDE)
- **`consecutives.m`** - Utility function for analyzing consecutive repeated values in vectors

## Requirements

### MATLAB Toolboxes
- Image Processing Toolbox (for `VideoReader` and `imshow`)
- Spreadsheet functionality (for `xlsread`)

### System Requirements
- MATLAB R2016b or later (GUI created with GUIDE v2.5)
- Windows system (paths use Windows backslash notation)

## Input Data Structure

The application requires the following directory structure:

```
SessionFolder/
├── Data worksheet (*.xls or *.xlsx)
├── Movies/
│   ├── Block 1/
│   │   ├── video_001.avi (or .mp4)
│   │   ├── video_002.avi
│   │   └── ...
│   ├── Block 2/
│   │   └── ...
├── Processed_1/
│   └── Results/
│       └── Tracks/
│           ├── video_001_tracks.mat
│           ├── video_002_tracks.mat
│           └── ...
├── Processed_2/
│   └── ...
└── Mouse ID/
    ├── 1 snap.png
    ├── 2 snap.png
    └── ...
```

### Data Worksheet Format

The Excel worksheet should contain the following columns:
- **Column 1**: Trial number
- **Column 2**: Block number
- **Columns 3-5**: Mouse IDs (or "Mice 1", "Mice 2", "Mice 3" or "Mouse 1", "Mouse 2", "Mouse 3")

## Usage

### Starting the Application

```matlab
bias_identityCorrectorGUI
```

### Basic Workflow

1. **Load Session Data**
   - Click "Load Session" button
   - Select the Excel worksheet containing trial/block information
   - The GUI will extract mouse IDs and session details

2. **Navigate Trials**
   - Use "Next" / "Past" buttons to move between trials within a block
   - Or directly enter a block number and frame number in the text fields
   - Click "Random Frame" to jump to a random frame in the current video

3. **Reorder Mouse Identities**
   - Use the radio buttons to change the mouse correspondence (e.g., swap Mouse A and B)
   - The video overlay will update immediately with the new ordering
   - Mouse ID reference images display at the top for visual verification

4. **Correct Tracking Positions**
   - Check the "Correct Position" checkbox to enter correction mode
   - Click on the video to place the cursor at the correct animal position
   - The frame automatically advances to the next frame
   - Press Enter to exit correction mode

5. **Save Changes**
   - Click "Commit Change" to save the corrected tracking data
   - The reordered mouse identities are saved to the original tracks file

### Controls

| Control | Function |
|---------|----------|
| Load Session | Load an Excel worksheet with session data |
| Next / Past | Navigate to next/previous trial |
| Random Frame | Jump to a random frame in current video |
| Frame slider | Scroll through frames manually |
| Block / Trial / Frame input | Jump directly to specific position |
| Radio buttons (123, 132, 213, 231, 312, 321) | Reorder mouse identities |
| Correct Position checkbox | Enable position correction mode |
| Commit Change | Save corrected tracking data |

## Output

The corrected tracking data is saved to the original `.mat` file with:
- `astrctTrackers` - Array of tracker structures with reordered mouse identities
- `strMovieFileName` - Movie filename metadata

## Function: `consecutives.m`

Utility function for identifying consecutive occurrences of a target value in a vector or matrix.

**Usage:**
```matlab
[result, y] = consecutives(vector, target)
```

**Inputs:**
- `vector` - Input vector or matrix (if matrix, must be 1xN)
- `target` - Integer value to search for

**Outputs:**
- `result` - Vector of consecutive counts
- `y` - Matrix same size as input with cumulative count for each element

## Author Notes

- Last modified: October 14, 2016 (GUIDE v2.5)
- Original code for neuroscience behavioral experiments
- Compatible with MOTR (multi-object tracking) output format
- Part of the "Single neurons in the medial prefrontal cortex encode social group influence and conformity" study

## Known Limitations

- Windows-only paths (backslash directory separators)
- Requires specific directory naming conventions
- `xlsread` is deprecated in MATLAB R2019b+; consider updating to `readtable()` or `readmatrix()`
- GUI created with GUIDE (deprecated in newer MATLAB versions; consider migration to App Designer)

## Troubleshooting

**"File not found" error:**
- Verify the Excel worksheet filename matches expected format
- Ensure Movies and Processed directories exist in the session folder
- Check Mouse ID image filenames match mouse IDs in the worksheet

**Video won't load:**
- Verify video files are named correctly: `{prefix}_Block_{N}_Trial_{NN}.avi` or `.mp4`
- Ensure VideoReader is available (Image Processing Toolbox)

**Tracks file error:**
- Confirm `*_tracks.mat` files exist in the Processed directory
- Verify the mat file contains `astrctTrackers` and `strMovieFileName` variables

## License & Citation

This code is provided as supplementary material for the paper under an MIT license:
> "Single neurons in the medial prefrontal cortex encode social group influence and conformity"  
> Nature Neuroscience (forthcoming)

If you use this tool, please cite the above publication.
