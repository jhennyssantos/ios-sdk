//
//  PP.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 16/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

enum PP: UInt8 {
    case PP_OK = 0
    case PP_PROCESSING = 1
    case PP_NOTIFY = 2
    case PP_F1 = 4
    case PP_F2 = 5
    case PP_F3 = 6
    case PP_F4 = 7
    case PP_BACKSP = 8
    case PP_UNDEFINED_9 = 9
    case PP_INVCALL = 10
    case PP_INVPARM = 11
    case PP_TIMEOUT = 12
    case PP_CANCEL = 13
    case PP_ALREADYOPEN = 14
    case PP_NOTOPEN = 15
    case PP_EXECERR = 16
    case PP_INVMODEL = 17
    case PP_NOFUNC = 18
    case PP_UNDEFINED_19 = 19
    case PP_TABEXP = 20 // Tabelas expiradas (pelo “time-stamp”)
    case PP_TABERR = 21 // Erro ao tentar gravar tabelas (falta de espaço, por exemplo)
    case PP_NOAPPLIC = 22
    case PP_UNDEFINED_23 = 23
    case PP_PORTERR = 30 // Erro de comunicação: porta serial do pinpad provavelmente ocupada
    case PP_COMMERR = 31 // Erro de comunicação: pinpad provavelmente desconectado ou problemas com a interface serial
    case PP_UNKNOWNSTAT = 32
    case PP_RSPERR = 33 // Mensagem recebida do pinpad possui formato inválido.
    case PP_COMMTOUT = 34 // Tempo esgotado ao esperar pela resposta do pinpad (no caso de comandos não blocantes).
    case PP_INTERR = 40 // Erro interno do pinpad
    case PP_MCDATAERR = 41
    case PP_ERRPIN = 42 // Erro na captura do PIN -Master Key pode não estar presente.
    case PP_NOCARD = 43
    case PP_PINBUSY = 44
    case PP_SAMERR = 50
    case PP_NOSAM = 51
    case PP_SAMINV = 52
    case PP_DUMBCARD = 60
    case PP_ERRCARD = 61
    case PP_CARDINV = 62
    case PP_CARDBLOCKED = 63
    case PP_CARDNAUTH = 64
    case PP_CARDEXPIRED = 65
    case PP_CARDERRSTRUCT = 66
    case PP_CARDINVALIDAT = 67
    case PP_CARDPROBLEMS = 68
    case PP_CARDINVDATA = 69
    case PP_CARDAPPNAV = 70
    case PP_CARDAPPNAUT = 71
    case PP_NOBALANCE = 72
    case PP_LIMITEXC = 73
    case PP_CARDNOTEFFECT = 74
    case PP_VCINVCURR = 75
    case PP_ERRFALLBACK = 76
    case PP_CTLSSMULTIPLE = 80
    case PP_CTLSSCOMMERR = 81
    case PP_CTLSSINVALIDAT = 82
    case PP_CTLSSPROBLEMS = 83
    case PP_CTLSSAPPNAV = 84
    case PP_CTLSSAPPNAUT = 85

    //case PPLOGICLAYER_TIMEOUTPROCESSING = 1005
}
