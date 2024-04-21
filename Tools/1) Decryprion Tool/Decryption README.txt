GGXrdRevelator v0.2 by gdkchan/Labryz
Guilty Gear XRD -REVELATOR- UPK/Steam AH3 PAC decrypter

Usage:
GGXrdRevelator [-e] (-revel|-sign) infile
-revel  Decrypts GG Xrd REVELATOR files
-sign  Decrypts GG Xrd SIGN files
-e, when added, encrypts the input file. Otherwise, the program decrypts the file.

Examples:
GGXrdRevelator -revel ELP_VOICE_JPN_A_SF.upk
GGXrdRevelator -e -sign chara_split_28.pac

The output file name is the input name with .dec or .enc extension
depending on if you used the -e flag.