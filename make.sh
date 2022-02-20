clear
make -f os.make

ls -lh kernel/kernel.bin

cd kernel/
rm kernel.bin
cd ..

cd boot/ 
rm bootsec.bin
cd ..

rm tmp.img

ls -lh kernel/
