# Configure paths for (X)MedCon library
# fix by Hannes Hofmann 2007-06-28 for more than 3 version numbers
# stolen from Elliot Lee 2000-01-10
# stolen from Raph Levien 98-11-18
# stolen from Manish Singh    98-9-30
# stolen back from Frank Belew
# stolen from Manish Singh
# Shamelessly stolen from Owen Taylor

dnl AM_PATH_XMEDCON([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for XMEDCON, and define XMEDCON_CFLAGS and XMEDCON_LIBS
dnl
AC_DEFUN([AM_PATH_XMEDCON],
[dnl
dnl Get the cflags and libraries from the xmedcon-config script
dnl
AC_ARG_WITH(xmedcon-prefix,[  --with-xmedcon-prefix=PFX   Prefix where XMEDCON is installed (optional)],
            xmedcon_prefix="$withval", xmedcon_prefix="")
AC_ARG_WITH(xmedcon-exec-prefix,[  --with-xmedcon-exec-prefix=PFX Exec prefix where XMEDCON is installed (optional)],
            xmedcon_exec_prefix="$withval", xmedcon_exec_prefix="")
AC_ARG_ENABLE(xmedcontest, [  --disable-xmedcontest       Do not try to compile and run a test XMEDCON program],
		    , enable_xmedcontest=yes)

  if test x$xmedcon_exec_prefix != x ; then
     xmedcon_args="$xmedcon_args --exec-prefix=$xmedcon_exec_prefix"
     if test x${XMEDCON_CONFIG+set} = xset ; then
        XMEDCON_CONFIG=$xmedcon_exec_prefix/xmedcon-config
     fi
  fi
  if test x$xmedcon_prefix != x ; then
     xmedcon_args="$xmedcon_args --prefix=$xmedcon_prefix"
     if test x${XMEDCON_CONFIG+set} = xset ; then
        XMEDCON_CONFIG=$xmedcon_prefix/bin/xmedcon-config
     fi
  fi

  AC_PATH_PROG(XMEDCON_CONFIG, xmedcon-config, no)
  min_xmedcon_version=ifelse([$1], ,0.5.2,$1)
  AC_MSG_CHECKING(for XMEDCON - version >= $min_xmedcon_version)
  no_xmedcon=""
  if test "$XMEDCON_CONFIG" = "no" ; then
    no_xmedcon=yes
  else
    XMEDCON_CFLAGS=`$XMEDCON_CONFIG $xmedconconf_args --cflags`
    XMEDCON_LIBS=`$XMEDCON_CONFIG $xmedconconf_args --libs`

    xmedcon_major_version=`$XMEDCON_CONFIG $xmedcon_args --version | \
           sed 's/^\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\1/'`
    xmedcon_minor_version=`$XMEDCON_CONFIG $xmedcon_args --version | \
           sed 's/^\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\2/'`
    xmedcon_micro_version=`$XMEDCON_CONFIG $xmedcon_config_args --version | \
           sed 's/^\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\3/'`
    if test "x$enable_xmedcontest" = "xyes" ; then
      ac_save_CFLAGS="$CFLAGS"
      ac_save_LIBS="$LIBS"
      CFLAGS="$CFLAGS $XMEDCON_CFLAGS"
      LIBS="$LIBS $XMEDCON_LIBS"
dnl
dnl Now check if the installed XMEDCON is sufficiently new. (Also sanity
dnl checks the results of xmedcon-config to some extent
dnl
      rm -f conf.xmedcontest
      AC_TRY_RUN([
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <medcon.h>

char*
my_strdup (char *str)
{
  char *new_str;

  if (str)
    {
      new_str = (char *) malloc ((strlen (str) + 1) * sizeof(char));
      strcpy (new_str, str);
    }
  else
    new_str = NULL;

  return new_str;
}

int main ()
{
  int major, minor, micro;
  char *tmp_version;

  system ("touch conf.xmedcontest");

  /* HP/UX 9 (%@#!) writes to sscanf strings */
  tmp_version = my_strdup("$min_xmedcon_version");
  if (sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) != 3) {
     printf("%s, bad version string\n", "$min_xmedcon_version");
     exit(1);
   }

   if (($xmedcon_major_version > major) ||
      (($xmedcon_major_version == major) && ($xmedcon_minor_version > minor)) ||
      (($xmedcon_major_version == major) && ($xmedcon_minor_version == minor) && ($xmedcon_micro_version >= micro)))
    {
      return 0;
    }
  else
    {
      printf("\n*** 'xmedcon-config --version' returned %d.%d.%d, but the minimum version\n", $xmedcon_major_version, $xmedcon_minor_version, $xmedcon_micro_version);
      printf("*** of XMEDCON required is %d.%d.%d. If xmedcon-config is correct, then it is\n", major, minor, micro);
      printf("*** best to upgrade to the required version.\n");
      printf("*** If xmedcon-config was wrong, set the environment variable XMEDCON_CONFIG\n");
      printf("*** to point to the correct copy of xmedcon-config, and remove the file\n");
      printf("*** config.cache before re-running configure\n");
      return 1;
    }
}

],, no_xmedcon=yes,[echo $ac_n "cross compiling; assumed OK... $ac_c"])
       CFLAGS="$ac_save_CFLAGS"
       LIBS="$ac_save_LIBS"
     fi
  fi
  if test "x$no_xmedcon" = x ; then
     AC_MSG_RESULT(yes)
     ifelse([$2], , :, [$2])
  else
     AC_MSG_RESULT(no)
     if test "$XMEDCON_CONFIG" = "no" ; then
       echo "*** The xmedcon-config script installed by XMEDCON could not be found"
       echo "*** If XMEDCON was installed in PREFIX, make sure PREFIX/bin is in"
       echo "*** your path, or set the XMEDCON_CONFIG environment variable to the"
       echo "*** full path to xmedcon-config."
     else
       if test -f conf.xmedcontest ; then
        :
       else
          echo "*** Could not run XMEDCON test program, checking why..."
          CFLAGS="$CFLAGS $XMEDCON_CFLAGS"
          LIBS="$LIBS $XMEDCON_LIBS"
          AC_TRY_LINK([
#include <stdio.h>
#include <medcon.h>
],      [ return 0; ],
        [ echo "*** The test program compiled, but did not run. This usually means"
          echo "*** that the run-time linker is not finding XMEDCON or finding the wrong"
          echo "*** version of XMEDCON. If it is not finding XMEDCON, you'll need to set your"
          echo "*** LD_LIBRARY_PATH environment variable, or edit /etc/ld.so.conf to point"
          echo "*** to the installed location  Also, make sure you have run ldconfig if that"
          echo "*** is required on your system"
	  echo "***"
          echo "*** If you have an old version installed, it is best to remove it, although"
          echo "*** you may also be able to get things to work by modifying LD_LIBRARY_PATH"],
        [ echo "*** The test program failed to compile or link. See the file config.log for the"
          echo "*** exact error that occured. This usually means XMEDCON was incorrectly installed"
          echo "*** or that you have moved XMEDCON since it was installed. In the latter case, you"
          echo "*** may want to edit the xmedcon-config script: $XMEDCON_CONFIG" ])
          CFLAGS="$ac_save_CFLAGS"
          LIBS="$ac_save_LIBS"
       fi
     fi
     XMEDCON_CFLAGS=""
     XMEDCON_LIBS=""
     ifelse([$3], , :, [$3])
  fi
  AC_SUBST(XMEDCON_CFLAGS)
  AC_SUBST(XMEDCON_LIBS)
  rm -f conf.xmedcontest
])
