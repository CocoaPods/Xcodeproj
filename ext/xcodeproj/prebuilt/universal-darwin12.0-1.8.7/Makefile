
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/universal-darwin12.0
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
#prefix = $(DESTDIR)/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr
prefix = /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr
mandir = $(DESTDIR)/usr/share/man
rubylibdir = $(libdir)/ruby/$(ruby_version)
oldincludedir = $(DESTDIR)/usr/include
includedir = $(prefix)/include
vendorarchdir = $(vendorlibdir)/$(sitearch)
sbindir = $(exec_prefix)/sbin
dvidir = $(docdir)
sysconfdir = $(prefix)/etc
sitedir = $(DESTDIR)/Library/Ruby/Site
htmldir = $(docdir)
libdir = $(exec_prefix)/lib
datadir = $(datarootdir)
sitearchdir = $(DESTDIR)./.gem.20131016-42808-1s3ls2p
docdir = $(datarootdir)/doc/$(PACKAGE)
archdir = $(rubylibdir)/$(arch)
datarootdir = $(prefix)/share
sharedstatedir = $(prefix)/com
vendorlibdir = $(vendordir)/$(ruby_version)
infodir = $(DESTDIR)/usr/share/info
vendordir = $(libdir)/ruby/vendor_ruby
psdir = $(docdir)
pdfdir = $(docdir)
sitelibdir = $(DESTDIR)./.gem.20131016-42808-1s3ls2p
bindir = $(exec_prefix)/bin
localstatedir = $(prefix)/var
localedir = $(datarootdir)/locale
libexecdir = $(exec_prefix)/libexec

CC = xcrun cc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)

RUBY_EXTCONF_H = extconf.h
CFLAGS   =  -fno-common -arch i386 -arch x86_64 -g -Os -pipe -fno-common -DENABLE_DTRACE  -fno-common  -pipe -fno-common $(cflags) -std=c99 
INCFLAGS = -I. -I. -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/universal-darwin12.0 -I.
DEFS     = 
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\"  -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE  
CXXFLAGS = $(CFLAGS) 
ldflags  = -L. -arch i386 -arch x86_64  -ObjC -framework CoreFoundation
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = cc -arch i386 -arch x86_64 -pipe -bundle -undefined dynamic_lookup
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = universal-darwin12.0
sitearch = universal-darwin12.0
ruby_version = 1.8
ruby = /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED)  -lpthread -ldl -lobjc  
SRCS = xcodeproj_ext.c
OBJS = xcodeproj_ext.o
TARGET = xcodeproj_ext
DLLIB = $(TARGET).bundle
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR    = $(sitelibdir)$(target_prefix)
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).bundle $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h $(RUBY_EXTCONF_H)
