###
## Automate building for the simulator, updating the binaries, and reloading simulator.
###

export SIMJECT = 1

make

sudo rm -rf /opt/simject/Barmoji.*

cp .theos/obj/iphone_simulator/x86_64/Barmoji.dylib /opt/simject/Barmoji.dylib
cp Barmoji.plist /opt/simject/Barmoji.plist

resim