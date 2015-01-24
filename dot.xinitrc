export LANG=ja_JP.UTF-8
mozc_server_start
export XIM=ibus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=xim
export XMODIFIERS=@im=ibus
export XIM_PROGRAM="ibus-daemon"
export XIM_ARGS="--daemonize --xim"
#vmware-user-suid-wrapper &
exec mate-session
