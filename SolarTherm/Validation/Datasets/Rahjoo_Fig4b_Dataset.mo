within SolarTherm.Validation.Datasets;

package Rahjoo_Fig4b_Dataset "Provides the initial temerature and enthalpy distributions of the validation case used by Niedermeier (2018) based on Pacheco (2002) experimental data"
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  package Fluid = SolarTherm.Materials.Air_Table;
  package Filler = SolarTherm.Materials.Geopolymer_Rahjoo_2022;
  //Niedermeier's Simulation Output
  constant SI.Length zdL_sim_0h[5] = {0.0,0.1,0.5,0.9,1.0};
  constant SI.Temperature T_K_0h[5] = {320.0,320.0,320.0,320.0,320.0};
  constant SI.Time T_inlet_times[267] = {501.05, 3810.10, 5597.89, 6803.38, 8297.46, 9584.67, 10603.72, 11837.29, 12963.61, 14143.55, 15001.69, 16273.58, 17307.95, 18326.99, 19560.57, 20847.78, 21974.09, 23261.30, 24548.52, 25835.73, 27122.94, 28553.18, 29789.31, 30662.77, 31842.72, 33478.55, 35489.82, 40638.67, 47718.34, 54798.01, 61877.67, 68742.81, 71991.48, 73945.29, 75209.51, 77324.22, 79071.15, 80735.33, 83116.68, 85047.49, 86549.24, 88265.53, 90839.95, 94241.87, 96417.87, 100494.04, 106930.10, 114009.77, 121089.44, 126881.89, 129713.76, 127847.30, 127847.30, 133226.01, 135248.77, 135034.24, 137501.40, 140397.62, 141942.28, 143615.65, 144581.06, 145439.20, 146741.74, 147477.29, 148120.90, 149500.05, 150373.52, 151246.98, 152626.14, 153752.45, 154878.76, 155752.23, 157131.38, 158418.60, 159062.20, 160349.41, 161636.63, 165201.21, 171934.32, 178462.33, 186361.83, 191371.23, 192207.92, 193387.86, 194621.44, 195855.02, 196605.89, 197954.40, 198781.90, 200092.09, 200896.60, 202275.76, 203195.19, 204390.46, 205401.84, 206689.06, 207976.27, 209355.43, 210228.89, 211337.32, 212757.34, 213584.84, 214519.60, 215940.90, 217147.66, 218381.24, 219132.11, 220572.56, 221400.05, 223422.82, 225997.24, 232235.27, 236763.02, 237367.62, 235973.14, 241202.44, 242731.00, 244125.48, 244845.71, 245627.23, 247879.85, 249488.87, 250969.16, 252936.76, 253994.11, 254959.52, 256246.73, 257319.41, 258392.08, 259464.76, 260751.97, 262039.19, 263418.34, 263970.00, 265257.22, 266544.43, 267923.58, 268797.05, 270752.62, 277485.73, 283778.77, 286567.73, 289821.52, 291451.99, 292771.38, 293790.42, 295024.00, 296311.21, 297544.79, 298081.13, 299368.34, 300655.55, 302034.71, 302800.91, 303980.85, 304517.19, 306190.57, 307172.07, 308539.73, 309773.31, 310524.18, 311757.76, 313366.78, 313849.48, 315274.61, 316102.10, 317818.39, 320156.82, 325756.19, 331548.65, 331977.72, 333881.72, 332514.06, 337708.88, 339271.92, 340880.94, 342168.15, 343192.07, 344742.58, 346443.54, 349569.62, 350856.83, 352401.49, 353323.99, 354718.47, 356112.95, 356890.64, 357936.50, 359223.71, 360602.87, 361154.53, 362441.75, 363820.90, 364694.37, 365567.83, 368556.00, 375571.31, 379604.58, 383037.14, 380784.52, 384163.45, 385182.50, 386347.12, 387542.38, 388921.54, 389687.74, 390867.68, 391771.80, 393120.30, 394192.98, 395426.56, 396660.14, 397411.01, 398841.25, 399985.44, 400874.23, 401916.26, 403346.49, 404597.95, 405471.41, 406206.96, 408137.78, 410068.60, 411815.53, 417148.27, 424227.94, 429376.78, 429698.59, 429698.59, 430812.52, 434203.83, 435651.94, 436732.28, 438280.00, 439567.22, 440425.36, 441927.10, 443428.85, 444930.60, 448363.17, 449811.28, 451259.39, 452546.61, 453941.09, 454906.50, 455925.54, 456959.91, 458339.06, 459626.27, 461020.75, 461449.82, 462844.30, 465418.73, 470117.05, 476360.03, 485370.52, 492450.19, 495944.05, 496771.54, 498886.25, 499851.66, 501092.90, 502640.62, 504035.10, 505483.21, 507172.68, 507896.74};
  constant SI.Temperature T_inlet_TK[267] = {302.63, 327.43, 344.13, 358.37, 371.85, 385.60, 398.91, 411.83, 426.56, 440.21, 453.17, 465.81, 480.93, 495.03, 509.08, 524.03, 538.53, 553.86, 570.67, 587.00, 604.89, 622.57, 640.07, 653.59, 668.08, 684.67, 696.14, 707.52, 712.85, 714.72, 714.99, 718.51, 731.66, 743.20, 755.26, 768.92, 782.22, 794.99, 810.22, 825.07, 836.17, 847.67, 858.10, 867.77, 880.94, 893.80, 900.67, 902.32, 904.20, 905.85, 872.47, 894.60, 884.03, 858.17, 830.45, 847.21, 808.99, 764.29, 748.89, 733.24, 719.79, 706.34, 693.24, 680.70, 670.23, 657.56, 645.11, 631.70, 616.48, 601.23, 587.56, 574.14, 557.53, 541.94, 529.29, 514.24, 497.80, 483.47, 475.87, 473.49, 473.38, 492.92, 507.84, 518.73, 532.31, 545.30, 557.63, 571.05, 584.15, 599.07, 612.41, 624.84, 639.45, 654.34, 669.96, 688.63, 706.10, 722.40, 736.12, 751.27, 766.78, 780.02, 792.71, 806.65, 822.74, 835.77, 848.09, 862.28, 873.67, 886.25, 896.22, 902.95, 881.94, 869.74, 903.72, 855.34, 841.84, 827.84, 816.18, 806.23, 776.46, 741.88, 726.03, 709.77, 695.46, 683.87, 670.12, 657.92, 643.11, 628.14, 613.35, 596.07, 579.83, 567.55, 553.98, 536.82, 520.28, 506.80, 490.19, 479.23, 477.27, 493.27, 517.07, 540.61, 557.35, 570.75, 584.06, 599.97, 613.01, 625.18, 639.41, 656.88, 672.93, 687.05, 699.94, 711.91, 727.23, 744.58, 759.71, 773.50, 785.66, 799.75, 815.30, 827.60, 839.30, 852.68, 865.62, 879.37, 889.05, 886.84, 874.43, 849.15, 864.34, 835.60, 821.65, 808.23, 795.83, 781.22, 752.69, 740.92, 692.57, 678.13, 665.04, 652.55, 640.69, 628.54, 614.91, 601.41, 586.52, 571.12, 559.10, 545.88, 530.64, 517.45, 503.47, 488.45, 484.63, 510.48, 540.46, 520.49, 558.67, 571.63, 584.63, 598.22, 611.80, 625.42, 637.35, 650.67, 666.21, 682.01, 696.80, 711.38, 723.87, 739.10, 752.85, 764.73, 777.50, 791.34, 806.23, 817.42, 829.09, 842.54, 857.35, 870.24, 880.06, 883.16, 882.11, 871.31, 860.74, 845.39, 834.27, 824.36, 815.01, 804.07, 791.66, 780.22, 753.65, 741.93, 730.11, 675.13, 662.52, 649.43, 635.95, 622.54, 609.89, 596.55, 582.37, 567.19, 551.46, 538.10, 525.37, 511.00, 494.77, 485.00, 479.77, 477.79, 475.39, 463.89, 451.81, 429.34, 419.00, 406.53, 394.34, 381.77, 367.29, 353.00, 346.80
};
    
  constant SI.Time T_Pos1_times[220] = {1378.69, 7653.85, 12051.83, 14787.16, 17716.39, 19464.03, 22331.65, 24097.99, 26203.50, 27582.66, 28869.87, 30984.58, 29053.76, 32593.59, 35218.83, 33880.81, 33559.00, 38432.02, 39535.35, 41282.28, 43488.93, 45511.69, 48040.14, 50864.86, 52974.45, 56407.02, 60912.26, 67026.52, 73301.68, 77404.67, 80470.74, 82840.84, 85323.33, 86978.31, 89184.96, 91161.75, 93138.54, 95667.00, 98241.42, 101137.65, 104194.78, 108217.32, 113687.97, 120445.83, 127525.50, 133317.96, 136986.51, 139754.02, 142650.24, 143165.13, 144688.33, 146511.88, 147992.18, 149174.07, 151145.85, 151660.73, 152626.14, 154878.76, 155844.17, 157131.38, 158311.33, 159598.54, 161958.43, 161636.63, 162923.84, 163843.28, 165391.00, 166969.36, 168716.29, 170647.11, 172899.73, 175724.45, 178830.10, 183841.04, 189403.63, 196391.36, 199931.19, 202183.81, 204114.63, 206045.45, 208217.62, 210228.89, 212382.50, 211194.30, 214412.33, 215699.54, 218874.67, 216986.76, 217952.16, 219837.01, 221420.49, 222850.72, 224763.66, 225859.33, 227974.03, 229358.30, 230931.56, 234006.56, 237439.13, 242999.17, 247944.21, 249453.11, 250583.00, 252706.90, 253994.11, 255603.12, 257625.89, 259172.21, 260537.44, 261395.58, 261781.74, 263197.68, 264720.88, 266360.54, 267188.03, 268797.05, 269655.19, 271049.67, 272336.88, 273256.32, 274804.04, 276566.30, 278772.95, 281025.57, 284114.88, 290357.86, 296472.11, 299644.17, 301406.43, 303781.64, 307037.98, 305804.40, 310777.72, 309666.04, 312812.56, 316043.59, 314814.89, 317213.79, 318032.92, 319191.41, 320993.51, 321830.20, 323289.04, 325193.04, 328974.23, 331870.45, 337341.11, 342811.76, 345064.38, 347317.00, 348926.02, 350937.29, 352948.55, 354718.47, 355791.15, 356925.12, 359304.17, 360028.22, 361690.87, 362978.08, 364613.92, 365981.58, 367268.79, 368105.48, 369950.48, 372498.09, 373383.05, 375589.70, 378531.90, 384967.96, 391210.94, 393978.45, 396231.07, 398483.69, 402637.87, 400897.21, 402023.52, 405287.53, 406206.96, 407601.44, 408942.29, 411999.42, 410926.74, 414206.07, 415861.06, 417791.87, 420294.79, 422940.72, 425354.25, 430020.39, 437100.06, 441927.10, 444455.56, 446110.54, 448041.36, 449900.67, 451152.13, 453190.21, 455121.03, 456040.47, 457824.18, 459350.44, 460545.71, 462915.82, 464315.40, 465579.63, 467717.32, 469923.97, 471854.79, 474107.41, 476932.13, 479792.60, 478612.66, 483761.50, 488266.75, 494059.20, 499208.05, 503069.69, 505873.97, 507574.93};
  constant SI.Temperature T_Pos1_TK[220] = {315.03, 319.02, 332.79, 345.02, 358.09, 370.60, 384.15, 397.55, 411.39, 423.49, 434.87, 454.33, 443.17, 469.52, 501.05, 485.51, 478.55, 516.16, 528.51, 541.62, 555.13, 567.14, 578.78, 590.66, 600.69, 611.97, 622.60, 633.26, 643.19, 653.45, 664.35, 676.29, 688.30, 699.62, 711.49, 722.43, 733.24, 744.04, 756.17, 768.05, 779.70, 792.03, 803.59, 812.65, 817.50, 810.62, 797.30, 784.92, 773.51, 761.95, 748.36, 736.10, 724.14, 710.46, 698.08, 683.98, 671.76, 659.19, 643.67, 629.28, 617.10, 604.03, 593.13, 583.50, 572.35, 560.42, 547.30, 535.58, 523.75, 511.44, 498.64, 486.07, 475.55, 463.58, 450.75, 455.71, 465.50, 476.14, 487.67, 499.84, 513.46, 527.57, 555.37, 539.41, 569.57, 581.19, 623.38, 593.10, 605.09, 638.56, 649.78, 665.36, 685.41, 704.25, 721.50, 733.08, 744.97, 756.87, 767.17, 776.46, 771.56, 758.39, 745.15, 731.06, 718.16, 706.90, 693.31, 680.12, 669.44, 659.58, 648.52, 636.32, 623.90, 609.95, 597.81, 586.92, 575.74, 564.00, 551.99, 540.66, 529.69, 518.98, 505.52, 493.35, 481.20, 473.82, 481.89, 492.63, 503.60, 516.85, 544.42, 529.13, 576.30, 560.28, 593.38, 629.24, 610.02, 645.64, 658.04, 668.97, 681.27, 692.93, 704.60, 715.13, 727.63, 739.96, 749.39, 744.52, 733.42, 721.55, 710.95, 697.82, 684.19, 672.12, 659.52, 647.96, 635.27, 622.48, 609.65, 598.53, 585.56, 572.83, 562.35, 552.23, 542.98, 533.87, 518.97, 506.77, 495.89, 490.45, 499.93, 510.72, 523.49, 537.46, 571.87, 552.12, 559.39, 585.59, 596.94, 608.61, 618.82, 647.70, 632.54, 664.90, 677.81, 692.41, 706.61, 719.67, 729.51, 743.28, 743.06, 728.19, 716.43, 705.28, 694.26, 679.29, 666.88, 654.72, 641.27, 629.43, 618.17, 606.66, 593.90, 582.23, 566.52, 554.16, 540.45, 527.37, 515.12, 503.08, 490.61, 479.81, 526.97, 469.26, 458.66, 448.79, 438.61, 427.40, 416.48, 410.27};
  
  constant SI.Time T_Pos2_times[167] = {1056.89, 1700.50, 10067.38, 12320.00, 14250.82, 15859.83, 17790.65, 19560.57, 21008.68, 22617.70, 23904.91, 25449.56, 26801.14, 27766.55, 29053.76, 30340.97, 31628.18, 32915.40, 34202.61, 35747.26, 37420.64, 39351.46, 41006.44, 43488.93, 46109.32, 49077.06, 52223.58, 57372.43, 63808.49, 69600.95, 74749.80, 79255.04, 84403.89, 86334.71, 88909.13, 91161.75, 93736.18, 95988.80, 98563.22, 101781.25, 105321.09, 109826.33, 113044.36, 124307.47, 131194.06, 135087.87, 137501.40, 138834.58, 140719.43, 143293.85, 142328.44, 144259.26, 145010.13, 147048.22, 148442.70, 151821.63, 154235.16, 156165.97, 157774.99, 159384.00, 160671.22, 161636.63, 162923.84, 164532.85, 166141.87, 168072.69, 170003.51, 172256.13, 174830.55, 177726.78, 180944.81, 185174.22, 189365.32, 193816.93, 206045.45, 208298.07, 210711.60, 211837.91, 213125.12, 214412.33, 215485.01, 217094.02, 218595.77, 219818.62, 221105.83, 222264.33, 223744.62, 225261.69, 226319.04, 228142.60, 229215.27, 230502.48, 232709.13, 235079.24, 239512.97, 247879.85, 249488.87, 259142.96, 261717.38, 263648.20, 265579.02, 266866.23, 268475.25, 269762.46, 272015.08, 272980.49, 274911.31, 277163.93, 279416.55, 281669.17, 284243.60, 289070.64, 294541.30, 297759.33, 300011.95, 309344.24, 310309.65, 312240.47, 313849.48, 315780.30, 316745.71, 318032.92, 319320.13, 321159.01, 322216.36, 323503.57, 325112.59, 327365.21, 330189.93, 334123.07, 341351.27, 344206.24, 357936.50, 360510.93, 363085.35, 370165.02, 373383.05, 377673.76, 382393.54, 388185.99, 391725.82, 393978.45, 395909.26, 404276.14, 406206.96, 407815.98, 409424.99, 411355.81, 413544.07, 414960.01, 416826.46, 418987.14, 421285.74, 423655.84, 426480.56, 431307.60, 438172.74, 452546.61, 456408.24, 458017.26, 464775.12, 478934.46, 482152.49, 488803.09, 495024.61, 503230.59, 506931.33};
  constant SI.Temperature T_Pos2_TK[167] = {320.89, 310.38, 337.03, 348.24, 359.93, 370.41, 385.18, 398.87, 410.99, 422.52, 434.64, 448.26, 462.02, 473.10, 484.71, 499.36, 512.92, 526.97, 540.06, 554.58, 569.63, 583.59, 595.75, 608.17, 620.57, 632.22, 643.98, 655.17, 664.82, 671.42, 683.29, 701.06, 725.55, 736.44, 751.32, 761.57, 772.25, 781.74, 793.36, 805.46, 816.32, 827.36, 833.37, 838.71, 836.92, 830.24, 811.76, 801.36, 791.82, 768.89, 782.17, 753.57, 739.32, 726.91, 715.55, 704.30, 683.89, 668.88, 651.43, 635.99, 625.66, 615.10, 601.46, 588.68, 576.60, 561.63, 549.78, 536.34, 524.09, 512.32, 500.99, 490.09, 477.31, 481.11, 527.05, 542.58, 560.47, 572.03, 583.04, 594.76, 607.04, 622.62, 637.79, 651.31, 664.66, 675.99, 691.05, 706.34, 720.03, 733.08, 744.86, 756.29, 768.91, 781.42, 793.57, 775.98, 767.57, 723.15, 700.58, 684.97, 665.04, 654.48, 638.63, 628.54, 607.41, 597.81, 581.96, 566.35, 550.74, 538.26, 526.13, 513.76, 516.65, 528.89, 540.66, 589.40, 599.25, 616.54, 630.46, 648.11, 658.80, 671.40, 683.89, 697.56, 710.53, 721.23, 733.96, 748.36, 762.05, 774.54, 775.35, 759.01, 695.78, 675.85, 653.03, 598.77, 573.79, 548.18, 535.55, 537.71, 550.02, 561.15, 574.91, 617.02, 635.75, 651.83, 663.28, 681.25, 696.64, 709.13, 722.11, 734.81, 746.61, 757.35, 767.87, 777.85, 774.00, 714.03, 687.61, 675.37, 623.74, 538.58, 524.17, 504.16, 489.91, 455.29, 441.65};
  
  constant SI.Time T_Pos3_times[217] = {-230.32, 10389.18, 14250.82, 15859.83, 17468.85, 20418.71, 22746.42, 23547.35, 25100.18, 25835.73, 26939.05, 29268.29, 30019.17, 30855.86, 32834.95, 34846.21, 33237.20, 35811.62, 38064.25, 39029.65, 41139.25, 43052.19, 46109.32, 48719.50, 51258.17, 55119.81, 59946.85, 66382.92, 73140.78, 76966.66, 79255.04, 82666.15, 85691.10, 87049.82, 88587.33, 91126.00, 93736.18, 95988.80, 98885.03, 102103.06, 105857.43, 109405.51, 114243.81, 121089.44, 128169.11, 133961.56, 136995.71, 140075.82, 142604.27, 142730.70, 145031.59, 146318.80, 148120.90, 149592.00, 151145.85, 153269.75, 152368.70, 155987.19, 157131.38, 158311.33, 159705.81, 161314.82, 161743.89, 162977.47, 163781.98, 166375.91, 167567.00, 170237.54, 173350.26, 175409.80, 178298.87, 181802.95, 185099.00, 187541.77, 193081.38, 197971.12, 201468.70, 203256.49, 204886.96, 206903.59, 208812.96, 209263.48, 210228.89, 211516.10, 213339.65, 214126.28, 215331.77, 216879.49, 217952.16, 219847.23, 221298.92, 221813.80, 223351.30, 225551.67, 226273.07, 228162.10, 230216.44, 231306.99, 232111.50, 234685.92, 238869.36, 244983.62, 249488.87, 250096.72, 252385.09, 254315.91, 255531.61, 256597.79, 258306.27, 259679.30, 261629.62, 262897.33, 264452.71, 265900.82, 270459.70, 267938.91, 269486.63, 272068.71, 269762.46, 273624.10, 276725.11, 278692.49, 280820.78, 283645.96, 287912.15, 291516.35, 295721.24, 298958.77, 301513.70, 303046.09, 305096.44, 306930.71, 308378.83, 309574.10, 311854.30, 312562.27, 313978.20, 314493.09, 316874.43, 318097.28, 318676.53, 319687.91, 321009.60, 322967.23, 324871.24, 326767.58, 330100.54, 334123.07, 340201.58, 343192.07, 346351.59, 349017.96, 347960.61, 350708.31, 353350.81, 355475.66, 358365.57, 360051.21, 361476.34, 362727.79, 364533.47, 366678.82, 368556.00, 369807.46, 372015.39, 373897.93, 376958.64, 378674.92, 383537.72, 389239.16, 392610.78, 395090.13, 396633.32, 398161.89, 399899.62, 401782.17, 403310.74, 404356.60, 405563.36, 408183.75, 409700.83, 411784.88, 412526.01, 414380.76, 415700.15, 417516.04, 420366.30, 424128.92, 428733.18, 435491.04, 439080.39, 442606.47, 445466.94, 448041.36, 449392.94, 451178.94, 454109.65, 453029.31, 458339.06, 459197.20, 460729.60, 463487.91, 462522.50, 466834.66, 468121.87, 471211.18, 473259.02, 476073.99, 478934.46, 481830.69, 485312.01, 488910.35, 493040.16, 498380.56, 501818.23, 504964.75, 507253.13};
  constant SI.Temperature T_Pos3_TK[217] = {319.34, 340.01, 351.44, 362.73, 376.35, 391.26, 404.68, 416.89, 427.25, 437.40, 452.48, 468.99, 482.31, 495.51, 508.68, 525.86, 514.24, 539.46, 554.24, 564.43, 576.62, 590.48, 603.81, 615.95, 628.30, 639.48, 652.18, 662.60, 671.56, 683.57, 694.13, 704.55, 714.80, 726.00, 739.24, 752.66, 764.51, 774.50, 785.06, 797.06, 808.94, 820.27, 830.68, 839.54, 843.34, 834.87, 825.65, 811.33, 797.59, 786.39, 774.93, 761.36, 747.08, 730.80, 718.11, 698.48, 709.13, 684.78, 669.12, 654.76, 642.10, 629.90, 616.78, 603.61, 594.20, 582.12, 567.60, 553.46, 539.79, 526.78, 515.74, 504.64, 493.33, 483.04, 476.84, 487.57, 502.29, 512.91, 526.47, 539.70, 551.32, 563.16, 573.55, 584.90, 597.81, 611.73, 626.35, 639.67, 654.78, 668.18, 682.04, 694.73, 707.30, 722.89, 736.94, 748.43, 759.70, 770.69, 783.10, 793.31, 802.00, 797.47, 783.90, 772.46, 762.63, 752.25, 738.25, 724.50, 712.44, 699.51, 686.26, 672.46, 661.20, 648.71, 601.37, 634.62, 622.23, 584.20, 613.17, 571.75, 558.24, 544.74, 532.84, 520.42, 506.99, 504.54, 509.87, 525.46, 539.06, 551.02, 565.01, 578.90, 592.52, 603.98, 617.16, 627.16, 639.25, 651.35, 667.80, 682.85, 694.93, 708.19, 721.36, 735.26, 749.02, 761.71, 774.42, 783.92, 778.32, 768.25, 757.25, 737.82, 750.04, 725.15, 713.43, 696.83, 680.46, 667.72, 656.56, 645.14, 631.72, 614.85, 599.19, 587.03, 573.19, 560.80, 545.99, 533.08, 524.86, 530.09, 543.59, 555.00, 568.33, 579.56, 592.57, 605.97, 619.18, 630.34, 641.65, 656.12, 672.19, 685.75, 701.02, 716.19, 730.65, 743.59, 757.01, 770.62, 784.05, 780.78, 770.25, 758.95, 747.16, 734.61, 722.24, 710.42, 689.43, 701.78, 673.36, 663.76, 647.96, 622.83, 636.71, 604.34, 590.31, 571.50, 556.51, 543.01, 530.81, 519.24, 507.65, 497.00, 487.63, 475.41, 464.08, 453.47, 444.40};
  
  constant SI.Time Velocity_times[125] = {2269.31, 9883.33, 13712.56, 14451.88, 14817.91, 19493.95, 26548.36, 33603.16, 40657.96, 47712.75, 54767.55, 61822.35, 68877.15, 75931.94, 82986.74, 90041.54, 97096.34, 104746.74, 109167.34, 109452.59, 110427.74, 111333.39, 118172.73, 119475.77, 120195.94, 121173.36, 121761.88, 124837.53, 131728.98, 138783.78, 145838.58, 152893.37, 159948.17, 167002.97, 174057.77, 181112.56, 188167.36, 195222.16, 202276.96, 209331.75, 216799.92, 219717.18, 220915.38, 222070.66, 229124.05, 236337.50, 236541.47, 237418.81, 237491.91, 237521.21, 237759.62, 239847.86, 243118.80, 244074.66, 244801.30, 252121.35, 259176.14, 265967.94, 266628.66, 267148.25, 268378.57, 269122.26, 272552.86, 279148.98, 286152.12, 289245.68, 289826.89, 290488.29, 290992.37, 295700.58, 301685.63, 308740.27, 315795.06, 322849.86, 329904.58, 336320.79, 336938.01, 338241.09, 338812.84, 340077.79, 347131.57, 354294.91, 358849.60, 359417.25, 360394.56, 361023.12, 365607.50, 371592.10, 378542.23, 381405.08, 381489.65, 383413.20, 383503.09, 387292.59, 388947.69, 389606.99, 390220.56, 391690.59, 398528.60, 405583.40, 412638.20, 419692.99, 426747.79, 434228.86, 436555.56, 437356.58, 439101.90, 445740.91, 447471.08, 447923.36, 448419.49, 450204.09, 457532.36, 464587.16, 471641.96, 478696.75, 485751.55, 492806.35, 500076.08, 504351.42, 506491.09, 506957.29, 507618.41, 508279.37, 515986.85};
  constant SI.Velocity Velocity_uflow[125] = {4.182, 4.227, 4.770, 5.388, 5.978, 6.296, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.374, 7.098, 6.402, 7.721, 8.296, 8.335, 7.865, 7.392, 6.925, 6.417, 6.236, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.342, 6.928, 7.732, 8.335, 8.367, 8.406, 8.879, 9.353, 10.660, 9.984, 11.485, 12.497, 11.807, 11.158, 10.496, 10.469, 10.469, 10.371, 9.925, 9.483, 9.010, 8.499, 8.354, 8.367, 8.326, 7.942, 7.392, 6.930, 6.398, 6.282, 6.301, 6.305, 6.305, 6.305, 6.307, 6.243, 6.800, 7.467, 7.935, 8.344, 8.367, 8.329, 7.924, 7.403, 6.938, 6.390, 6.275, 6.305, 6.254, 5.803, 5.287, 4.850, 4.317, 4.127, 4.517, 4.985, 5.626, 6.236, 6.305, 6.305, 6.305, 6.305, 6.305, 6.335, 6.909, 7.541, 8.170, 8.309, 7.850, 7.392, 6.931, 6.384, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.279, 6.285, 5.935, 5.352, 4.896, 4.443, 4.182};
  
  function Initial_Temperature_f "Input a height array, obtain a Temperature array"
    input SI.Length[:] z_f;
    output SI.Temperature[size(z_f,1)] T_f;
  protected
    Integer N_f = size(z_f,1);
    Integer j;
    SI.Length z_data[5] = {0.0,0.1,0.5,0.9,1.0};
    SI.Temperature T_data[5] = {320.0,320.0,320.0,320.0,320.0};
  algorithm
    for i in 1:N_f loop
        T_f[i] := SolarTherm.Utilities.Interpolation.Interpolate1D(z_data,T_data,z_f[i]);
    end for;
  end Initial_Temperature_f;
  
  function Initial_Enthalpy_f "Input height array, output enthalpy array based on constant SolarSalt properties"
    input SI.Length[:] z_f;
    output SI.SpecificEnthalpy[size(z_f,1)] h_f;
  protected
    Integer N_f = size(z_f,1);
    Integer j;
    SI.Temperature[N_f] T_f;
    SI.Length z_data[5] = {0.0,0.1,0.5,0.9,1.0};
    SI.Temperature T_data[5] = {320.0,320.0,320.0,320.0,320.0};
  algorithm
    for i in 1:N_f loop
       T_f[i] := SolarTherm.Utilities.Interpolation.Interpolate1D(z_data,T_data,z_f[i]);
       h_f[i] := Fluid.h_Tf(T_f[i]);
    end for;
  end Initial_Enthalpy_f;
  
  function Initial_Temperature_p "Input height array and number of particle CVs, output enthalpy array based on constant Quartzite_Sand properties"
    input SI.Length[:] z_f;
    input Integer N_p;
    output SI.Temperature[size(z_f,1),N_p] T_p;
  protected
    Integer N_f = size(z_f,1);
    Integer j;
    SI.Length z_data[5] = {0.0,0.1,0.5,0.9,1.0};
    SI.Temperature T_data[5] = {320.0,320.0,320.0,320.0,320.0};
  algorithm
    for i in 1:N_f loop
      for k in 1:N_p loop
          T_p[i,k] := SolarTherm.Utilities.Interpolation.Interpolate1D(z_data,T_data,z_f[i]);
      end for;
    end for;
  end Initial_Temperature_p;
  
  function Initial_Enthalpy_p "Input height array and number of particle CVs, output enthalpy array based on constant Quartzite_Sand properties"
    input SI.Length[:] z_f;
    input Integer N_p;
    output SI.SpecificEnthalpy[size(z_f,1),N_p] h_p;
  protected
    Integer N_f = size(z_f,1);
    Real T;
    Integer j;
    SI.Length z_data[5] = {0.0,0.1,0.5,0.9,1.0};
    SI.Temperature T_data[5] = {320.0,320.0,320.0,320.0,320.0};
  algorithm
    for i in 1:N_f loop
      for k in 1:N_p loop
        T := SolarTherm.Utilities.Interpolation.Interpolate1D(z_data,T_data,z_f[i]);
        h_p[i,k] := Filler.h_Tf(T,0);
      end for;
    end for;
  end Initial_Enthalpy_p;
  
  function Timeseries_uflow "Input time(s) output mass flow rate (kg/s)"
    input SI.Time t;
    output SI.Velocity uflow;
  protected
    SI.Time t_data[125] = {2269.31, 9883.33, 13712.56, 14451.88, 14817.91, 19493.95, 26548.36, 33603.16, 40657.96, 47712.75, 54767.55, 61822.35, 68877.15, 75931.94, 82986.74, 90041.54, 97096.34, 104746.74, 109167.34, 109452.59, 110427.74, 111333.39, 118172.73, 119475.77, 120195.94, 121173.36, 121761.88, 124837.53, 131728.98, 138783.78, 145838.58, 152893.37, 159948.17, 167002.97, 174057.77, 181112.56, 188167.36, 195222.16, 202276.96, 209331.75, 216799.92, 219717.18, 220915.38, 222070.66, 229124.05, 236337.50, 236541.47, 237418.81, 237491.91, 237521.21, 237759.62, 239847.86, 243118.80, 244074.66, 244801.30, 252121.35, 259176.14, 265967.94, 266628.66, 267148.25, 268378.57, 269122.26, 272552.86, 279148.98, 286152.12, 289245.68, 289826.89, 290488.29, 290992.37, 295700.58, 301685.63, 308740.27, 315795.06, 322849.86, 329904.58, 336320.79, 336938.01, 338241.09, 338812.84, 340077.79, 347131.57, 354294.91, 358849.60, 359417.25, 360394.56, 361023.12, 365607.50, 371592.10, 378542.23, 381405.08, 381489.65, 383413.20, 383503.09, 387292.59, 388947.69, 389606.99, 390220.56, 391690.59, 398528.60, 405583.40, 412638.20, 419692.99, 426747.79, 434228.86, 436555.56, 437356.58, 439101.90, 445740.91, 447471.08, 447923.36, 448419.49, 450204.09, 457532.36, 464587.16, 471641.96, 478696.75, 485751.55, 492806.35, 500076.08, 504351.42, 506491.09, 506957.29, 507618.41, 508279.37, 515986.85};
    SI.Velocity uflow_data[125] = {4.182, 4.227, 4.770, 5.388, 5.978, 6.296, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.374, 7.098, 6.402, 7.721, 8.296, 8.335, 7.865, 7.392, 6.925, 6.417, 6.236, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.342, 6.928, 7.732, 8.335, 8.367, 8.406, 8.879, 9.353, 10.660, 9.984, 11.485, 12.497, 11.807, 11.158, 10.496, 10.469, 10.469, 10.371, 9.925, 9.483, 9.010, 8.499, 8.354, 8.367, 8.326, 7.942, 7.392, 6.930, 6.398, 6.282, 6.301, 6.305, 6.305, 6.305, 6.307, 6.243, 6.800, 7.467, 7.935, 8.344, 8.367, 8.329, 7.924, 7.403, 6.938, 6.390, 6.275, 6.305, 6.254, 5.803, 5.287, 4.850, 4.317, 4.127, 4.517, 4.985, 5.626, 6.236, 6.305, 6.305, 6.305, 6.305, 6.305, 6.335, 6.909, 7.541, 8.170, 8.309, 7.850, 7.392, 6.931, 6.384, 6.305, 6.305, 6.305, 6.305, 6.305, 6.305, 6.279, 6.285, 5.935, 5.352, 4.896, 4.443, 4.182};
  algorithm
    uflow := SolarTherm.Utilities.Interpolation.Interpolate1D(t_data,uflow_data,t);
  end Timeseries_uflow;
  
  function Timeseries_TinletK "Input time(s) output inlet fluid temperature (K)"
    input SI.Time t;
    output SI.MassFlowRate T_inlet;
  protected
    SI.Time t_data[267] = {501.05, 3810.10, 5597.89, 6803.38, 8297.46, 9584.67, 10603.72, 11837.29, 12963.61, 14143.55, 15001.69, 16273.58, 17307.95, 18326.99, 19560.57, 20847.78, 21974.09, 23261.30, 24548.52, 25835.73, 27122.94, 28553.18, 29789.31, 30662.77, 31842.72, 33478.55, 35489.82, 40638.67, 47718.34, 54798.01, 61877.67, 68742.81, 71991.48, 73945.29, 75209.51, 77324.22, 79071.15, 80735.33, 83116.68, 85047.49, 86549.24, 88265.53, 90839.95, 94241.87, 96417.87, 100494.04, 106930.10, 114009.77, 121089.44, 126881.89, 129713.76, 127847.30, 127847.30, 133226.01, 135248.77, 135034.24, 137501.40, 140397.62, 141942.28, 143615.65, 144581.06, 145439.20, 146741.74, 147477.29, 148120.90, 149500.05, 150373.52, 151246.98, 152626.14, 153752.45, 154878.76, 155752.23, 157131.38, 158418.60, 159062.20, 160349.41, 161636.63, 165201.21, 171934.32, 178462.33, 186361.83, 191371.23, 192207.92, 193387.86, 194621.44, 195855.02, 196605.89, 197954.40, 198781.90, 200092.09, 200896.60, 202275.76, 203195.19, 204390.46, 205401.84, 206689.06, 207976.27, 209355.43, 210228.89, 211337.32, 212757.34, 213584.84, 214519.60, 215940.90, 217147.66, 218381.24, 219132.11, 220572.56, 221400.05, 223422.82, 225997.24, 232235.27, 236763.02, 237367.62, 235973.14, 241202.44, 242731.00, 244125.48, 244845.71, 245627.23, 247879.85, 249488.87, 250969.16, 252936.76, 253994.11, 254959.52, 256246.73, 257319.41, 258392.08, 259464.76, 260751.97, 262039.19, 263418.34, 263970.00, 265257.22, 266544.43, 267923.58, 268797.05, 270752.62, 277485.73, 283778.77, 286567.73, 289821.52, 291451.99, 292771.38, 293790.42, 295024.00, 296311.21, 297544.79, 298081.13, 299368.34, 300655.55, 302034.71, 302800.91, 303980.85, 304517.19, 306190.57, 307172.07, 308539.73, 309773.31, 310524.18, 311757.76, 313366.78, 313849.48, 315274.61, 316102.10, 317818.39, 320156.82, 325756.19, 331548.65, 331977.72, 333881.72, 332514.06, 337708.88, 339271.92, 340880.94, 342168.15, 343192.07, 344742.58, 346443.54, 349569.62, 350856.83, 352401.49, 353323.99, 354718.47, 356112.95, 356890.64, 357936.50, 359223.71, 360602.87, 361154.53, 362441.75, 363820.90, 364694.37, 365567.83, 368556.00, 375571.31, 379604.58, 383037.14, 380784.52, 384163.45, 385182.50, 386347.12, 387542.38, 388921.54, 389687.74, 390867.68, 391771.80, 393120.30, 394192.98, 395426.56, 396660.14, 397411.01, 398841.25, 399985.44, 400874.23, 401916.26, 403346.49, 404597.95, 405471.41, 406206.96, 408137.78, 410068.60, 411815.53, 417148.27, 424227.94, 429376.78, 429698.59, 429698.59, 430812.52, 434203.83, 435651.94, 436732.28, 438280.00, 439567.22, 440425.36, 441927.10, 443428.85, 444930.60, 448363.17, 449811.28, 451259.39, 452546.61, 453941.09, 454906.50, 455925.54, 456959.91, 458339.06, 459626.27, 461020.75, 461449.82, 462844.30, 465418.73, 470117.05, 476360.03, 485370.52, 492450.19, 495944.05, 496771.54, 498886.25, 499851.66, 501092.90, 502640.62, 504035.10, 505483.21, 507172.68, 507896.74};
    SI.Temperature T_data[267] = {302.63, 327.43, 344.13, 358.37, 371.85, 385.60, 398.91, 411.83, 426.56, 440.21, 453.17, 465.81, 480.93, 495.03, 509.08, 524.03, 538.53, 553.86, 570.67, 587.00, 604.89, 622.57, 640.07, 653.59, 668.08, 684.67, 696.14, 707.52, 712.85, 714.72, 714.99, 718.51, 731.66, 743.20, 755.26, 768.92, 782.22, 794.99, 810.22, 825.07, 836.17, 847.67, 858.10, 867.77, 880.94, 893.80, 900.67, 902.32, 904.20, 905.85, 872.47, 894.60, 884.03, 858.17, 830.45, 847.21, 808.99, 764.29, 748.89, 733.24, 719.79, 706.34, 693.24, 680.70, 670.23, 657.56, 645.11, 631.70, 616.48, 601.23, 587.56, 574.14, 557.53, 541.94, 529.29, 514.24, 497.80, 483.47, 475.87, 473.49, 473.38, 492.92, 507.84, 518.73, 532.31, 545.30, 557.63, 571.05, 584.15, 599.07, 612.41, 624.84, 639.45, 654.34, 669.96, 688.63, 706.10, 722.40, 736.12, 751.27, 766.78, 780.02, 792.71, 806.65, 822.74, 835.77, 848.09, 862.28, 873.67, 886.25, 896.22, 902.95, 881.94, 869.74, 903.72, 855.34, 841.84, 827.84, 816.18, 806.23, 776.46, 741.88, 726.03, 709.77, 695.46, 683.87, 670.12, 657.92, 643.11, 628.14, 613.35, 596.07, 579.83, 567.55, 553.98, 536.82, 520.28, 506.80, 490.19, 479.23, 477.27, 493.27, 517.07, 540.61, 557.35, 570.75, 584.06, 599.97, 613.01, 625.18, 639.41, 656.88, 672.93, 687.05, 699.94, 711.91, 727.23, 744.58, 759.71, 773.50, 785.66, 799.75, 815.30, 827.60, 839.30, 852.68, 865.62, 879.37, 889.05, 886.84, 874.43, 849.15, 864.34, 835.60, 821.65, 808.23, 795.83, 781.22, 752.69, 740.92, 692.57, 678.13, 665.04, 652.55, 640.69, 628.54, 614.91, 601.41, 586.52, 571.12, 559.10, 545.88, 530.64, 517.45, 503.47, 488.45, 484.63, 510.48, 540.46, 520.49, 558.67, 571.63, 584.63, 598.22, 611.80, 625.42, 637.35, 650.67, 666.21, 682.01, 696.80, 711.38, 723.87, 739.10, 752.85, 764.73, 777.50, 791.34, 806.23, 817.42, 829.09, 842.54, 857.35, 870.24, 880.06, 883.16, 882.11, 871.31, 860.74, 845.39, 834.27, 824.36, 815.01, 804.07, 791.66, 780.22, 753.65, 741.93, 730.11, 675.13, 662.52, 649.43, 635.95, 622.54, 609.89, 596.55, 582.37, 567.19, 551.46, 538.10, 525.37, 511.00, 494.77, 485.00, 479.77, 477.79, 475.39, 463.89, 451.81, 429.34, 419.00, 406.53, 394.34, 381.77, 367.29, 353.00, 346.80
};
  algorithm
    T_inlet := SolarTherm.Utilities.Interpolation.Interpolate1D(t_data,T_data,t);
  end Timeseries_TinletK;
    
end Rahjoo_Fig4b_Dataset;