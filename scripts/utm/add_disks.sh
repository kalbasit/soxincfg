#!/usr/bin/env bash

set -euo pipefail

# --- Script Usage ---
if [ $# -lt 3 ] || [ $# -gt 5 ]; then
  echo "Usage: $0 <VM_Name> <Num_Disks> <Size_in_MB> [<Disk_Prefix>] [<Disk_Format>]"
  echo "Arguments:"
  echo "  <VM_Name>      : The exact name of the UTM virtual machine."
  echo "  <Num_Disks>    : The number of virtual disks to add (e.g., 16)."
  echo "  <Size_in_MB>   : The size of each disk in Megabytes (e.g., 1024 for 1GB)."
  echo "  [<Disk_Prefix>]: Optional. Filename prefix for new disks. Defaults to 'added_disk'."
  echo "                 : Cannot contain spaces or slashes '/'. Example: 'zfs_disk'."
  echo "  [<Disk_Format>]: Optional. The disk image format (e.g., qcow2, raw). Defaults to 'qcow2'."
  echo "Example (3 args): $0 MyLinuxVM 16 1024"
  echo "Example (4 args): $0 MyLinuxVM 16 1024 zfs_pool_a"
  echo "Example (5 args): $0 MyLinuxVM 16 1024 zfs_pool_a raw"
  exit 1
fi

# --- Assign Arguments ---
VM_NAME="$1"
NUM_DISKS="$2"
DISK_SIZE_MB="$3"

# --- Assign Optional Arguments (with defaults) ---
DISK_PREFIX="added_disk" # Default prefix
DISK_FORMAT="qcow2"    # Default format
PREFIX_SOURCE="(default)"
FORMAT_SOURCE="(default)"

if [ $# -ge 4 ]; then
  DISK_PREFIX="$4"
  PREFIX_SOURCE="(from argument)"
  echo "Disk prefix specified: '${DISK_PREFIX}'."
fi

if [ $# -eq 5 ]; then
  DISK_FORMAT="$5"
  FORMAT_SOURCE="(from argument)"
  echo "Disk format specified: '${DISK_FORMAT}'."
fi

# Print defaults only if they were actually used
if [ "$PREFIX_SOURCE" == "(default)" ]; then
    echo "Disk prefix not specified, defaulting to '${DISK_PREFIX}'."
fi
if [ "$FORMAT_SOURCE" == "(default)" ]; then
    echo "Disk format not specified, defaulting to '${DISK_FORMAT}'."
fi


# --- Validate Arguments ---
# Validate Number of Disks (must be a positive integer)
if ! [[ "$NUM_DISKS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: <Num_Disks> must be a positive integer. Received: '$NUM_DISKS'"
    exit 1
fi

# Validate Disk Size (must be a positive integer)
if ! [[ "$DISK_SIZE_MB" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: <Size_in_MB> must be a positive integer. Received: '$DISK_SIZE_MB'"
    exit 1
fi

# Validate Disk Prefix (cannot be empty, cannot contain spaces or slashes)
if [ -z "$DISK_PREFIX" ]; then
    echo "Error: <Disk_Prefix> cannot be empty."
    exit 1
fi
if [[ "$DISK_PREFIX" =~ [/[:space:]] ]]; then
    echo "Error: <Disk_Prefix> cannot contain spaces or forward slashes ('/'). Received: '$DISK_PREFIX'"
    exit 1
fi


# Validate Disk Format (allow common formats, add more if needed)
case "$DISK_FORMAT" in
    qcow2|raw|vmdk|vdi)
        # Format is valid
        ;;
    *)
        echo "Error: <Disk_Format> is not recognized or supported. Received: '$DISK_FORMAT'"
        echo "Supported formats currently checked: qcow2, raw, vmdk, vdi"
        exit 1
        ;;
esac

# --- Configuration (Partially from Arguments, partially hardcoded) ---
VM_BASE_PATH="${HOME}/Library/Containers/com.utmapp.UTM/Data/Documents"
# --- IMPORTANT: Inspect your config.plist for an existing drive in the target VM ---
# --- Use the same Interface type unless you have a reason not to ---
DISK_INTERFACE="VirtIO" # Or "sata", "scsi-hd", "nvme", etc. Check target VM's plist!
DISK_INTERFACE_VERSION=1

# --- Construct qemu-img size argument (needs M suffix for Megabytes) ---
QEMU_DISK_SIZE="${DISK_SIZE_MB}M"

# --- Paths ---
VM_PATH="${VM_BASE_PATH}/${VM_NAME}.utm"
CONFIG_PLIST="${VM_PATH}/config.plist"
IMAGES_DIR="${VM_PATH}/Data"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

# --- Path for qemu-img (Prioritize Homebrew/PATH version) ---
echo "Attempting to find qemu-img in PATH (e.g., via Homebrew)..."
QEMU_IMG_PATH_WHICH=$(which qemu-img)

if [ -n "$QEMU_IMG_PATH_WHICH" ] && [ -f "$QEMU_IMG_PATH_WHICH" ]; then
  QEMU_IMG_PATH="$QEMU_IMG_PATH_WHICH"
  echo "Using qemu-img found in PATH: $QEMU_IMG_PATH"
else
  echo "qemu-img not found in PATH. Falling back to checking UTM bundle (might cause errors)..."
  QEMU_IMG_PATH_UTM="/Applications/UTM.app/Contents/Frameworks/qemu-img.framework/qemu-img"
  if [ -f "$QEMU_IMG_PATH_UTM" ]; then
    QEMU_IMG_PATH="$QEMU_IMG_PATH_UTM"
    echo "Using qemu-img found in UTM bundle: $QEMU_IMG_PATH"
    echo "WARNING: This bundled version may cause issues. Consider using the Homebrew version ('brew install qemu')."
  else
    echo "Error: qemu-img not found in PATH or in the UTM bundle."
    echo "Please install qemu (e.g., 'brew install qemu')."
    exit 1
  fi
fi

echo "Using qemu-img at: $QEMU_IMG_PATH"

# --- Safety Checks ---
# Check if the VM package directory exists
if [ ! -d "$VM_PATH" ]; then
  echo "Error: VM package not found for name '${VM_NAME}' at expected location:"
  echo "${VM_PATH}"
  echo "Please check the VM name and the VM_BASE_PATH variable in the script."
  exit 1
fi
# Check if config.plist exists within the package
if [ ! -f "$CONFIG_PLIST" ]; then
  echo "Error: config.plist not found within the VM package:"
  echo "${CONFIG_PLIST}"
  echo "The VM package might be corrupted or incomplete."
  exit 1
fi
# Check/Create Images directory
if [ ! -d "$IMAGES_DIR" ]; then
  echo "Warning: Images directory not found at ${IMAGES_DIR}"
  mkdir -p "$IMAGES_DIR"
  if [ $? -ne 0 ]; then # Check exit status after mkdir
      echo "Error: Failed to create Images directory at ${IMAGES_DIR}"
      exit 1
  fi
  echo "Created Images directory."
fi

echo "--- Configuration Summary ---"
echo "VM Name:         ${VM_NAME} (from argument)"
echo "VM Path:         ${VM_PATH}"
echo "Config File:     ${CONFIG_PLIST}"
echo "Images Dir:      ${IMAGES_DIR}"
echo "Disks to add:    ${NUM_DISKS} (from argument)"
echo "Size per disk:   ${DISK_SIZE_MB} MB (from argument)"
echo "Disk Prefix:     ${DISK_PREFIX} ${PREFIX_SOURCE}" # Corrected source text
echo "Disk Format:     ${DISK_FORMAT} ${FORMAT_SOURCE}" # Corrected source text
echo "Disk Interface:  ${DISK_INTERFACE} version ${DISK_INTERFACE_VERSION} (hardcoded in script)"
echo "---------------------------"
echo "Ensure VM '${VM_NAME}' is shut down and UTM is closed before proceeding."
echo "Have you backed up '${VM_NAME}.utm'? (Highly Recommended!)"
read -p "Press Enter to continue, or Ctrl+C to abort..."

# --- Determine starting index for new drives ---
DRIVE_COUNT=0
if $PLIST_BUDDY -c "Print :Drive" "$CONFIG_PLIST" >/dev/null 2>&1; then
    DRIVE_COUNT=$($PLIST_BUDDY -c "Print :Drive" "$CONFIG_PLIST" | grep -c "Dict {" || echo 0)
else
    echo "Creating :Drive array in plist..."
    if ! $PLIST_BUDDY -c "Add :Drive array" "$CONFIG_PLIST"; then
        echo "Error: Failed to add :Drive array to plist ${CONFIG_PLIST}"
        exit 1
    fi
fi

echo "Detected $DRIVE_COUNT existing drives. Adding $NUM_DISKS new drives..."

# --- Loop to create disks and add plist entries ---
for (( i=1; i<=NUM_DISKS; i++ ))
do
  DISK_INDEX_NUM=$((DRIVE_COUNT + i))
  DISK_FILENAME="${DISK_PREFIX}_${DISK_INDEX_NUM}.${DISK_FORMAT}"
  DISK_FULL_PATH="${IMAGES_DIR}/${DISK_FILENAME}"
  PLIST_INDEX=$((DISK_INDEX_NUM - 1)) # PlistBuddy array index is 0-based

  echo "Processing Disk ${i}/${NUM_DISKS} (Overall Index: ${DISK_INDEX_NUM}) -> ${DISK_FILENAME} at plist index ${PLIST_INDEX}"

  if [ -e "$DISK_FULL_PATH" ]; then
      echo "  Warning: Disk image file already exists, skipping creation: ${DISK_FULL_PATH}"
  else
      # 1. Create the disk image file
      echo "  Creating disk image: ${DISK_FULL_PATH} (${QEMU_DISK_SIZE})"
      if ! "$QEMU_IMG_PATH" create -f "$DISK_FORMAT" "$DISK_FULL_PATH" "$QEMU_DISK_SIZE"; then
        echo "  Error creating disk image ${DISK_FULL_PATH}. Aborting remaining steps."
        exit 1
      fi
      echo "  Disk image created successfully."
  fi

  # 2. Add the drive entry to config.plist
  echo "  Adding entry to config.plist..."
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX} dict" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:Identifier string $(uuidgen)" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:ImageName string $DISK_FILENAME" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:ImageType string Disk" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:Interface string $DISK_INTERFACE" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:InterfaceVersion integer $DISK_INTERFACE_VERSION" "$CONFIG_PLIST"
  $PLIST_BUDDY -c "Add :Drive:${PLIST_INDEX}:ReadOnly bool false" "$CONFIG_PLIST"

  echo "  Plist entry added successfully."

done

echo "--- Process Complete ---"
echo "Successfully added $NUM_DISKS virtual disks to VM '${VM_NAME}'."
echo "Configuration:"
echo "  Size: ${DISK_SIZE_MB} MB each"
echo "  Prefix: ${DISK_PREFIX}"
echo "  Format: ${DISK_FORMAT}"
echo "You can now open UTM, verify the hardware configuration for '${VM_NAME}', and start the VM."
echo "Inside the Linux VM, you should see new block devices."

exit 0
