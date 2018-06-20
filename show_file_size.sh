#!/bin/bash
declare -a filearray=(Resources/HD/Buttons/bt-green-disable.png
Resources/HD/Buttons/bt-green-enable.png
Resources/HD/Buttons/bt-orange-disable.png
Resources/HD/Buttons/bt-orange-enable.png
Resources/HD/Frames/fr-white-lost-tournament.png
Resources/HD/Graphics/gr-bottom-background.png
Resources/HD/Graphics/gr-bottom-corner.png
Resources/HD/Graphics/gr-label-background-lose.png
Resources/HD/Graphics/gr-label-background-select.png
Resources/HD/Graphics/gr-label-background-win.png
Resources/HD/Graphics/gr-label-background.png
Resources/HD/Graphics/gr-label-corner-lose.png
Resources/HD/Graphics/gr-label-corner-select.png
Resources/HD/Graphics/gr-label-corner-win.png
Resources/HD/Graphics/gr-top-background.png
Resources/HD/Graphics/gr-top-corner.png
Resources/HD/Icons/ic-medalBoost.png
Resources/HD/Icons/ic-points-background-select.png
Resources/HD/Icons/ic-points-background.png
Resources/HD/UIRetake/Battle/avatarlife_ph.png
Resources/HD/UIRetake/Battle/changedragon_ph.png
Resources/HD/UIRetake/Buttons/bt-leaderboard.png
Resources/HD/UIRetake/Frames/Battle/life-bar-frame.png
Resources/HD/UIRetake/Frames/fr-basic-transparent.png
Resources/HD/UIRetake/Graphics/Battle/gr-frame-avatar-small.png
Resources/HD/UIRetake/Graphics/Battle/gr-frame-small-avatar.png
Resources/HD/UIRetake/Graphics/Battle/gr-glow-thumbs-big.png
Resources/HD/UIRetake/Graphics/Battle/gr-glow-thumbs-small.png
Resources/HD/UIRetake/Graphics/Battle/gr-shines-wins.png
Resources/HD/UIRetake/Graphics/Battle/gr-stroke-selected-element.png
Resources/HD/UIRetake/Graphics/Chat/gr-info-bubble-chat.png
Resources/HD/UIRetake/Graphics/Chat/gr-noguild-info.png
Resources/HD/UIRetake/Graphics/Gatcha/gr-front-mask.png
Resources/HD/UIRetake/Graphics/TreeOfLife/gr-degree-filters.png
Resources/HD/UIRetake/Graphics/TreeOfLife/gr-glow-middle-recall.png
Resources/HD/UIRetake/Graphics/TreeOfLife/gr-header-filters.png
Resources/HD/UIRetake/Graphics/TreeOfLife/gr-summon-label.png
Resources/HD/UIRetake/Graphics/gr-front-mask.png
Resources/HD/UIRetake/Graphics/gr-noguild-info.png
Resources/HD/UIRetake/Graphics/gr-separator-gray-light.png
Resources/HD/UIRetake/Icons/Battle/ic-basic-attack.png
Resources/HD/UIRetake/Icons/Battle/ic-change-dragon.png
Resources/HD/UIRetake/Icons/PvpArenas/ic-cup-supa-smal.png
Resources/HD/UIRetake/Icons/PvpArenas/ic-gift-open.png
Resources/HD/UIRetake/Icons/PvpArenas/ic-user-smal.png
Resources/SD/Buttons/bt-green-disable.png
Resources/SD/Buttons/bt-green-enable.png
Resources/SD/Buttons/bt-orange-disable.png
Resources/SD/Buttons/bt-orange-enable.png
Resources/SD/Frames/fr-white-lost-tournament.png
Resources/SD/Graphics/gr-bottom-background.png
Resources/SD/Graphics/gr-bottom-corner.png
Resources/SD/Graphics/gr-label-background-lose.png
Resources/SD/Graphics/gr-label-background-select.png
Resources/SD/Graphics/gr-label-background-win.png
Resources/SD/Graphics/gr-label-background.png
Resources/SD/Graphics/gr-label-corner-lose.png
Resources/SD/Graphics/gr-label-corner-select.png
Resources/SD/Graphics/gr-label-corner-win.png
Resources/SD/Graphics/gr-top-background.png
Resources/SD/Graphics/gr-top-corner.png
Resources/SD/Icons/ic-medalBoost.png
Resources/SD/Icons/ic-points-background-select.png
Resources/SD/Icons/ic-points-background.png
Resources/SD/UIRetake/Battle/avatarlife_ph.png
Resources/SD/UIRetake/Battle/changedragon_ph.png
Resources/SD/UIRetake/Buttons/bt-leaderboard.png
Resources/SD/UIRetake/Frames/Battle/life-bar-frame.png
Resources/SD/UIRetake/Frames/fr-basic-transparent.png
Resources/SD/UIRetake/Graphics/Battle/gr-frame-small-avatar.png
Resources/SD/UIRetake/Graphics/Battle/gr-glow-thumbs-big.png
Resources/SD/UIRetake/Graphics/Battle/gr-glow-thumbs-small.png
Resources/SD/UIRetake/Graphics/Battle/gr-shines-wins.png
Resources/SD/UIRetake/Graphics/Battle/gr-stroke-selected-element.png
Resources/SD/UIRetake/Graphics/Chat/gr-info-bubble-chat.png
Resources/SD/UIRetake/Graphics/Chat/gr-noguild-info.png
Resources/SD/UIRetake/Graphics/Gatcha/gr-front-mask.png
Resources/SD/UIRetake/Graphics/TreeOfLife/gr-degree-filters.png
Resources/SD/UIRetake/Graphics/TreeOfLife/gr-glow-middle-recall.png
Resources/SD/UIRetake/Graphics/TreeOfLife/gr-header-filters.png
Resources/SD/UIRetake/Graphics/TreeOfLife/gr-summon-label.png
Resources/SD/UIRetake/Graphics/gr-front-mask.png
Resources/SD/UIRetake/Graphics/gr-noguild-info.png
Resources/SD/UIRetake/Graphics/gr-separator-gray-light.png
Resources/SD/UIRetake/Icons/Alliances/ic-alliance-chest.png
Resources/SD/UIRetake/Icons/Battle/ic-basic-attack.png
Resources/SD/UIRetake/Icons/Battle/ic-change-dragon.png
Resources/SD/UIRetake/Icons/PvpArenas/ic-cup-supa-smal.png
Resources/SD/UIRetake/Icons/PvpArenas/ic-gift-open.png
Resources/SD/UIRetake/Icons/PvpArenas/ic-world-ranking.png)

for file in "${filearray[@]}"
do
    FILEPATH=`dirname $file | cut -d'/' -f3-`
    FILENAME=`basename $file`
    LSRESULT=`ls -l $file`

    FILESIZE=`echo $LSRESULT | cut -d' ' -f5`

    echo -e "$FILENAME\t$FILESIZE\t$FILEPATH"
done
