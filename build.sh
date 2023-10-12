PLUGINNAME="test-plugin"

rm *.clap
odin build src -build-mode:dll
mv ./src.so ./$PLUGINNAME.clap

clap-validator -v trace validate ./$PLUGINNAME.clap
