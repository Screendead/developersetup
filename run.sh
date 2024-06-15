# !/bin/bash

# Function to handle each simulator
handle_simulator() {
    local UDID=$1
    local X=$2
    local Y=$3
    local ROTATE=$4

    echo "Handling simulator with UDID: $UDID"

    # Boot the device
    echo "Booting the device..."
    xcrun simctl boot "$UDID"

    # Wait a few seconds to ensure the device is fully booted
    sleep 5

    # Focus the Simulator app
    osascript -e 'tell application "Simulator" to activate'

    # Set the simulator to its physical size using cmd+1
    echo "Setting the simulator to its physical size..."
    osascript <<EOF
    tell application "System Events"
        tell application process "Simulator"
            key code 18 using {command down} -- cmd+1
        end tell
    end tell
EOF

    # Optionally rotate the simulator
    if [ "$ROTATE" = "left" ]; then
        echo "Rotating the simulator to the left..."
        osascript <<EOF
        tell application "System Events"
            tell application process "Simulator"
                key code 123 using {command down} -- cmd+left arrow
            end tell
        end tell
EOF
    fi

    # Move the simulator window to the specified position
    echo "Moving the simulator window to position ($X, $Y)..."
    osascript <<EOF
    tell application "System Events"
        tell application process "Simulator"
            set position of front window to {$X, $Y}
        end tell
    end tell
EOF
}

# Quit the Simulator app if it's running
echo "Quitting the Simulator app if it's running..."
killall "Simulator"
sleep 1

# Open the Simulator app
echo "Opening the Simulator app..."
open -a Simulator
sleep 5

# Focus the Simulator app
osascript -e 'tell application "Simulator" to activate'

# Close any open simulator windows
echo "Closing any open simulator windows..."
osascript <<EOF
tell application "System Events"
    tell application process "Simulator"
        repeat until (count of windows) = 0
            set frontWindow to front window
			key code 13 using {command down} -- cmd+w
			delay 0.5 -- add a small delay to ensure the window closes before the next iteration
        end repeat
    end tell
end tell
EOF

# # Get the UDIDs of the devices
echo "Getting the UDIDs of the devices..."
SE_UDID=$(xcrun simctl list | grep 'iPhone SE (3rd generation)' | grep -oE '([A-F0-9-]{36})' | head -n 1)
ProMax_UDID=$(xcrun simctl list | grep 'iPhone 15 Pro Max' | grep -oE '([A-F0-9-]{36})' | head -n 1)
Mini_UDID=$(xcrun simctl list | grep 'iPad mini (6th generation)' | grep -oE '([A-F0-9-]{36})' | head -n 1)
Pro_UDID=$(xcrun simctl list | grep 'iPad Pro 13-inch (M4)' | grep -oE '([A-F0-9-]{36})' | head -n 1)

# Handle each simulator individually
echo "Handling each simulator individually..."
handle_simulator "$SE_UDID" 848 -1440
handle_simulator "$ProMax_UDID" 1148 -1440
handle_simulator "$Mini_UDID" 1490 -1415
handle_simulator "$Pro_UDID" 2078 -1415 left

# Open VS Code with the project
echo "Opening VS Code with the project..."
open -a "Visual Studio Code" ~/development/seesay

# Wait a few seconds for VS Code to open
sleep 2

# Fullscreen VS Code
echo "Fullscreening VS Code..."
osascript <<EOF
tell application "System Events"
    tell application process "Code"
        set frontmost to true
        keystroke "f" using {control down, command down}
    end tell
end tell
EOF

# Wait a few seconds for VS Code to fullscreen
sleep 2

echo "Creating Terminal tabs in VS Code and running functions:watch..."
osascript <<EOF
tell application "Visual Studio Code"
    activate
    delay 1
    tell application "System Events"
        keystroke "\`" using {control down, shift down} -- open integrated terminal
        delay 1
        keystroke "cd ~/development/seesay/functions ; functions:watch" & return
    end tell
end tell
EOF

# Wait a few seconds for the terminal to start
sleep 1

echo "Creating Terminal tabs in VS Code and running emulators:start..."
osascript <<EOF
tell application "Visual Studio Code"
    activate
    delay 1
    tell application "System Events"
        key code 42 using {command down} -- open a new terminal tab
        delay 1
        keystroke "cd ~/development/seesay ; emulators:kill ; emulators:start" & return
    end tell
end tell
EOF

# # Function to set default Flutter device and start debugging
# set_device_and_debug() {
#     local UDID=$1

#     # Set default Flutter device
#     echo "Setting default Flutter device to $UDID..."
#     osascript <<EOF
# tell application "Visual Studio Code"
#     activate
#     delay 1
#     tell application "System Events"
#         keystroke "\`" using {control down, shift down} -- open integrated terminal
#         delay 1
#         keystroke "flutter config --device-id=$UDID" & return
#     end tell
# end tell
# EOF

#     # Wait a few seconds for the command to execute
#     sleep 1

#     # Start debugging by pressing F5
#     echo "Starting debugging by pressing F5..."
#     osascript <<EOF
# tell application "Visual Studio Code"
#     activate
#     delay 1
#     tell application "System Events"
#         key code 96 -- press F5
#     end tell
# end tell
# EOF
# }

# # Set default Flutter device and start debugging
# set_device_and_debug "$SE_UDID"