main: clean storydata.asm
	avra hellodave.asm

clean:
	rm -f hellodave.hex
	rm -f hellodave.eep.hex
	rm -f hellodave.obj
	rm -f storydata.asm
	rm -f hellodave.cof

storydata.asm:
	./data-to-asm.py

install: main
	sudo avrdude -p m128 -c osuisp2 -U flash:w:hellodave.hex
