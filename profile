# vim:fileencoding=utf-8:foldmethod=marker
# #
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022


# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
. "$HOME/.cargo/env"

#while :; do notify-send -t 12000 "Excuse:" "$(cat /home/batan/.config/lists/comments.md|sort -R|tail -n1)" && sleep 5m ;done

#{{{ >>>   functions - lisening to changes in clipbord and lc-gutenberg directory


#clear clipbord
xclip -selection clipboard /dev/null && xclip -selection primary /dev/null


#{{{   Text To Voice
#watch directory for changes
lc-clipboard_gutenberg() {
WATCH_DIR="/home/batan/.config/lc-gutenberg"
VOICE="en-US-EmmaNeural"  # Change this if needed

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read -r file; do
    [[ $file == *.txt ]] || continue

    base="${file%.txt}"
    txt="$WATCH_DIR/$file"
    mp3="$WATCH_DIR/$base.mp3"

    /home/batan/.local/bin/edge-tts --voice "$VOICE" -f "$txt" --write-media "$mp3" &>/dev/null
    mpv --no-terminal "$mp3" 
read -n1 -p "asd" fff
    rm -f "$txt" "$mp3"
done
}
#}}}

#{{{ >>> Move Reg
move_register() {
	   
        cat /home/batan/.config/lc-clipboard/register9|grep "http" >> /home/batan/.config/lc-clipboard/auto.register.md 2>/dev/null
		rm -f /home/batan/.config/lc-clipboard/register9 2>/dev/null 
		mv /home/batan/.config/lc-clipboard/register8 /home/batan/.config/lc-clipboard/register9 2>/dev/null 
		mv /home/batan/.config/lc-clipboard/register7 /home/batan/.config/lc-clipboard/register8 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register6 /home/batan/.config/lc-clipboard/register7 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register5 /home/batan/.config/lc-clipboard/register6 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register4 /home/batan/.config/lc-clipboard/register5 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register3 /home/batan/.config/lc-clipboard/register4 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register2 /home/batan/.config/lc-clipboard/register3 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register1 /home/batan/.config/lc-clipboard/register2 2>/dev/null
		touch /home/batan/.config/lc-clipboard/register1
}
#}}}

#{{{   lc-clipboard background
lc-clipboard-logic() {
    DIR_BASE="$HOME/.config/lc-clipboard"
    CONFIG_FILE="$DIR_BASE/config"
	TOGGLE_FILE="$DIR_BASE/toggle_register"
 #   mkdir -p "$DIR_BASE"
 #   touch "$CONFIG_FILE"

    previous_clipboard=""

    while true; do
        # Load config values (key=value format)
        [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
        current_clipboard=$(xclip -o -selection clipboard 2>/dev/null)
        cleaned_clipboard=$(echo "$current_clipboard" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty or unchanged clipboard
        [[ -z "$cleaned_clipboard" || "$cleaned_clipboard" == "$previous_clipboard" ]] && sleep 0.0001 && continue
		if [[ -f "$TOGGLE_FILE" ]]; then
			xclip -o -selection clipboard >> /home/batan/.config/lc-gutenberg/$(( $(ls /home/batan/.config/lc-gutenberg/*.txt|wc -l 2>/dev/null) + 1 )).txt
        else
			move_register
			echo "$cleaned_clipboard" > "$DIR_BASE/register1"
		fi


        # === Conditional Logic ===
        if [[ "$cleaned_clipboard" == http* ]]; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/urls.log"

        elif grep -qi youtube <<< "$cleaned_clipboard"; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/youtube.log"

        elif [[ "${LOG_PLAIN}" == "true" ]]; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/plain.log"

 #       elif [[ -n "$REDIRECT_PATH" ]]; then
 #           echo "$cleaned_clipboard" >> "$REDIRECT_PATH"
#
#        elif [[ "$CENSOR" == "true" ]]; then
#            echo "[CENSORED]" >> "$DIR_BASE/censored.log"

#        elif [[ "$cleaned_clipboard" == *password* ]]; then
#            echo "[SECRET]" >> "$DIR_BASE/secrets.log"

        fi

        previous_clipboard="$cleaned_clipboard"
        sleep 0.0001
    done
}
#}}}

lc-clipboard_gutenberg &
lc-clipboard-logic &



