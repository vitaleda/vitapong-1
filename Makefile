TITLE_ID = VITAPONG0
TARGET   = vitapong

SRCDIR   = src

OBJS     = $(SRCDIR)/main.o \
	   $(SRCDIR)/vita_audio.o \

HEADERS  = $(SRCDIR)/geometry.h \
	   $(SRCDIR)/graphics_constants.h \
	   $(SRCDIR)/graphics.h \
	   $(SRCDIR)/input.h \
	   $(SRCDIR)/psp2_utils.h \
	   $(SRCDIR)/utils.h \
	   $(SRCDIR)/vita2dpp.h \
	   $(SRCDIR)/vita_audio.h \

LIBS = -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lSceCtrl_stub -lScePgf_stub \
	-lSceTouch_stub -lSceAudio_stub \
	-lfreetype -lpng -ljpeg -lz -lm -lc \
	-lvita2d \

PREFIX    = arm-vita-eabi
CC        = $(PREFIX)-gcc
CXX       = $(PREFIX)-g++
STRIP     = $(PREFIX)-strip
CFLAGS    = -Wl,-q -Wall -O3
CXXFLAGS  = $(CFLAGS) -std=gnu++11 -fno-rtti -fno-exceptions
ASFLAGS   = $(CFLAGS)

all: $(TARGET).vpk

%.vpk: eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "$(TARGET)" param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin \
		--add sce_sys/icon0.png=sce_sys/icon0.png \
		--add sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
		--add data/beep.wav=data/beep.wav \
		--add data/boop.wav=data/boop.wav \
		$@

eboot.bin: $(TARGET).velf
	vita-make-fself -s $< $@

%.velf: %.elf
	$(STRIP) -g $<
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(OBJS) $(LIBS) -o $@

%.o: %.png
	$(PREFIX)-ld -r -b binary -o $@ $^

clean:
	@rm -rf $(TARGET).vpk $(TARGET).velf $(TARGET).elf $(OBJS) \
		eboot.bin param.sfo

vpksend: $(TARGET).vpk
	curl -T $(TARGET).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."

