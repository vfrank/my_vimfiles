
" -- NOTE: if you add something new, don't forget to copy this file to
"  ../examples !!

" --------- paths ----------

let $MACHINE_LOCAL_CONF__PATH__MICROCHIP_MAIN = "D:/ProgramFiles/Microchip"
let $MACHINE_LOCAL_CONF__PATH__MICROCHIP_MAIN_SECOND = "D:/projects/Microchip"
let $MACHINE_LOCAL_CONF__PATH__MICROCHIP_C30  = $MACHINE_LOCAL_CONF__PATH__MICROCHIP_MAIN.'/mplabc30/v3.31'
let $MACHINE_LOCAL_CONF__PATH__MICROCHIP_C18  = $MACHINE_LOCAL_CONF__PATH__MICROCHIP_MAIN.'/mplabc18/v3.44'
let $MACHINE_LOCAL_CONF__PATH__MICROCHIP_XC32 = $MACHINE_LOCAL_CONF__PATH__MICROCHIP_MAIN.'/xc32/v1.21'
let $MACHINE_LOCAL_CONF__PATH__MINGW_INCLUDE  = 'D:/mingw/lib/gcc/mingw32/4.6.2/include'
let $MACHINE_LOCAL_CONF__CMD__BROWSER         = 'start "D:/ProgramFiles/Mozilla Firefox/firefox.exe"'
let $MACHINE_LOCAL_CONF__PATH__QT_DOC_TAGS    = 'D:\Qt\4.8.3\doc\tags'

let $MACHINE_LOCAL_CONF__PATH__HI_TECH_MAIN     = "D:/projects/HtPicc"
let $MACHINE_LOCAL_CONF__PATH__HI_TECH_HTPICC18 = $MACHINE_LOCAL_CONF__PATH__HI_TECH_MAIN."/PICC-18/STD/9.51"
let $MACHINE_LOCAL_CONF__PATH__HI_TECH_HTPICC18_INCLUDE = $MACHINE_LOCAL_CONF__PATH__HI_TECH_HTPICC18.'/include'


" ----------- linux kernel paths -----------

let $MACHINE_LOCAL_CONF__LINUX_KERNEL_3_15_6__PATH          = '/home/dimon/projects/linux-3.15.6'
let $MACHINE_LOCAL_CONF__LINUX_KERNEL_3_15_6__TAGS          = '/home/dimon/projects/linux-3.15.6/.vimprj/.indexer_files_tags/linux_3_15_6'

let $MACHINE_LOCAL_CONF__LINUX_KERNEL_GENERIC__PATH         = $MACHINE_LOCAL_CONF__LINUX_KERNEL_3_15_6__PATH
let $MACHINE_LOCAL_CONF__LINUX_KERNEL_GENERIC__TAGS         = $MACHINE_LOCAL_CONF__LINUX_KERNEL_3_15_6__TAGS

