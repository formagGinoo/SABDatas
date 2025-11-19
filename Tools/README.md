# SABDatas - Tools

<table><tbody>
  <tr>
    <td>Frida</td>
    <td>Contains the runtime dumper for the tables, and the loader for it. Just edit the loader, for pointing to the game install path, and run that. The loader will compile the script, kill the fake game process created by the game Anti-Cheat, and attach to the game. The dumper will run multiples dumps, to make sure every table is dumped. So please don't kill the dumper right after the first dump.</td>
  </tr>
  <tr>
    <td>Lua</td>
    <td>Contains a slightly modified version of unluac.jar for properly decompile the game lua scripts. Also u can find a scripts to decompile all of them in a batch. This script run SABunluac.jar for every lua, and save the result in an output folder given. This works if you export the luas from the assetbundle and group them by container path. You can set this by going in AssetStudio->Options->Export options->Group exported assets by->container path. Else you would need to edit the script to make it save the decompiled luas properly.</td>
  </tr>
  <tr>
    <td>Proto</td>
    <td>Contains scripts for dumping protos from dump.cs, and also them all the MessagesIDs from the decompiled luas. Check the comments in the scripts for more details.</td>
  </tr>
</tbody>
</table>