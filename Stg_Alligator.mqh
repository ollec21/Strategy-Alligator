/**
 * @file
 * Implements Alligator strategy based on the Alligator indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_Alligator.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float Alligator_LotSize = 0;                // Lot size
INPUT int Alligator_SignalOpenMethod = 0;         // Signal open method (-63-63)
INPUT float Alligator_SignalOpenLevel = 36;       // Signal open level (-49-49)
INPUT int Alligator_SignalOpenFilterMethod = 36;  // Signal open filter method
INPUT int Alligator_SignalOpenBoostMethod = 36;   // Signal open filter method
INPUT int Alligator_SignalCloseMethod = 0;        // Signal close method (-63-63)
INPUT float Alligator_SignalCloseLevel = 36;      // Signal close level (-49-49)
INPUT int Alligator_PriceLimitMethod = 0;         // Price limit method
INPUT float Alligator_PriceLimitLevel = 10;       // Price limit level
INPUT int Alligator_TickFilterMethod = 0;         // Tick filter method
INPUT float Alligator_MaxSpread = 0;              // Max spread to trade (pips)
INPUT int Alligator_Shift = 2;                    // Shift
INPUT string __Alligator_Indi_Alligator_Parameters__ =
    "-- Alligator strategy: Alligator indicator params --";  // >>> Alligator strategy: Alligator indicator <<<
INPUT int Indi_Alligator_Period_Jaw = 16;                    // Jaw Period
INPUT int Indi_Alligator_Period_Teeth = 8;                   // Teeth Period
INPUT int Indi_Alligator_Period_Lips = 6;                    // Lips Period
INPUT int Indi_Alligator_Shift_Jaw = 5;                      // Jaw Shift
INPUT int Indi_Alligator_Shift_Teeth = 7;                    // Teeth Shift
INPUT int Indi_Alligator_Shift_Lips = 5;                     // Lips Shift
INPUT ENUM_MA_METHOD Indi_Alligator_MA_Method = 2;           // MA Method
INPUT ENUM_APPLIED_PRICE Indi_Alligator_Applied_Price = 4;   // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_Alligator_Params_Defaults : AlligatorParams {
  Indi_Alligator_Params_Defaults()
      : AlligatorParams(::Indi_Alligator_Period_Jaw, ::Indi_Alligator_Shift_Jaw, ::Indi_Alligator_Period_Teeth,
                        ::Indi_Alligator_Shift_Teeth, ::Indi_Alligator_Period_Lips, ::Indi_Alligator_Shift_Lips,
                        ::Indi_Alligator_MA_Method, ::Indi_Alligator_Applied_Price) {}
} indi_alli_defaults;

// Defines struct to store indicator parameter values.
struct Indi_Alligator_Params : public AlligatorParams {
  // Struct constructors.
  void Indi_Alligator_Params(AlligatorParams &_params, ENUM_TIMEFRAMES _tf) : AlligatorParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_Alligator_Params_Defaults : StgParams {
  Stg_Alligator_Params_Defaults()
      : StgParams(::Alligator_SignalOpenMethod, ::Alligator_SignalOpenFilterMethod, ::Alligator_SignalOpenLevel,
                  ::Alligator_SignalOpenBoostMethod, ::Alligator_SignalCloseMethod, ::Alligator_SignalCloseLevel,
                  ::Alligator_PriceLimitMethod, ::Alligator_PriceLimitLevel, ::Alligator_TickFilterMethod,
                  ::Alligator_MaxSpread, ::Alligator_Shift) {}
} stg_alli_defaults;

// Struct to define strategy parameters to override.
struct Stg_Alligator_Params : StgParams {
  Indi_Alligator_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_Alligator_Params(Indi_Alligator_Params &_iparams, StgParams &_sparams)
      : iparams(indi_alli_defaults, _iparams.tf), sparams(stg_alli_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Alligator : public Strategy {
 public:
  Stg_Alligator(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Alligator *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_Alligator_Params _indi_params(indi_alli_defaults, _tf);
    StgParams _stg_params(stg_alli_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_Alligator_Params>(_indi_params, _tf, indi_alli_m1, indi_alli_m5, indi_alli_m15, indi_alli_m30,
                                           indi_alli_h1, indi_alli_h4, indi_alli_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_alli_m1, stg_alli_m5, stg_alli_m15, stg_alli_m30, stg_alli_h1,
                               stg_alli_h4, stg_alli_h8);
    }
    // Initialize indicator.
    AlligatorParams alli_params(_indi_params);
    _stg_params.SetIndicator(new Indi_Alligator(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Alligator(_stg_params, "Alligator");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Indi_Alligator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result =
            (_indi[CURR].value[LINE_LIPS] >
                 _indi[CURR].value[LINE_TEETH] + _level_pips &&  // Check if Lips are above Teeth ...
             _indi[CURR].value[LINE_TEETH] > _indi[CURR].value[LINE_JAW] + _level_pips  // ... Teeth are above Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR].value[LINE_LIPS] > _indi[PREV].value[LINE_LIPS] &&    // Check if Lips increased.
                        _indi[CURR].value[LINE_TEETH] > _indi[PREV].value[LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[CURR].value[LINE_JAW] > _indi[PREV].value[LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV].value[LINE_LIPS] > _indi[PPREV].value[LINE_LIPS] &&    // Check if Lips increased.
                        _indi[PREV].value[LINE_TEETH] > _indi[PPREV].value[LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[PREV].value[LINE_JAW] > _indi[PPREV].value[LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR].value[LINE_LIPS] > _indi[PPREV].value[LINE_LIPS];  // Check if Lips increased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR].value[LINE_LIPS] - _indi[CURR].value[LINE_TEETH] >
                       _indi[CURR].value[LINE_TEETH] - _indi[CURR].value[LINE_JAW];
          if (METHOD(_method, 4))
            _result &=
                (_indi[PPREV].value[LINE_LIPS] <=
                     _indi[PPREV].value[LINE_TEETH] ||  // Check if Lips are below Teeth and ...
                 _indi[PPREV].value[LINE_LIPS] <= _indi[PPREV].value[LINE_JAW] ||  // ... Lips are below Jaw and ...
                 _indi[PPREV].value[LINE_TEETH] <= _indi[PPREV].value[LINE_JAW]    // ... Teeth are below Jaw ...
                );
        }
        break;
      case ORDER_TYPE_SELL:
        _result =
            (_indi[CURR].value[LINE_LIPS] + _level_pips <
                 _indi[CURR].value[LINE_TEETH] &&  // Check if Lips are below Teeth and ...
             _indi[CURR].value[LINE_TEETH] + _level_pips < _indi[CURR].value[LINE_JAW]  // ... Teeth are below Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR].value[LINE_LIPS] < _indi[PREV].value[LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[CURR].value[LINE_TEETH] < _indi[PREV].value[LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[CURR].value[LINE_JAW] < _indi[PREV].value[LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV].value[LINE_LIPS] < _indi[PPREV].value[LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[PREV].value[LINE_TEETH] < _indi[PPREV].value[LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[PREV].value[LINE_JAW] < _indi[PPREV].value[LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR].value[LINE_LIPS] < _indi[PPREV].value[LINE_LIPS];  // Check if Lips decreased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR].value[LINE_TEETH] - _indi[CURR].value[LINE_LIPS] >
                       _indi[CURR].value[LINE_JAW] - _indi[CURR].value[LINE_TEETH];
          if (METHOD(_method, 4))
            _result &= (_indi[PPREV].value[LINE_LIPS] >=
                            _indi[PPREV].value[LINE_TEETH] ||  // Check if Lips are above Teeth ...
                        _indi[PPREV].value[LINE_LIPS] >= _indi[PPREV].value[LINE_JAW] ||  // ... Lips are above Jaw ...
                        _indi[PPREV].value[LINE_TEETH] >= _indi[PPREV].value[LINE_JAW]    // ... Teeth are above Jaw ...
            );
        }
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_Alligator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0:
        _result = _indi[CURR].value[LINE_JAW] + _trail * _direction;
        break;
      case 1:
        _result = _indi[CURR].value[LINE_TEETH] + _trail * _direction;
        break;
      case 2:
        _result = _indi[CURR].value[LINE_LIPS] + _trail * _direction;
        break;
      case 3:
        _result = _indi[PREV].value[LINE_JAW] + _trail * _direction;
        break;
      case 4:
        _result = _indi[PREV].value[LINE_TEETH] + _trail * _direction;
        break;
      case 5:
        _result = _indi[PREV].value[LINE_LIPS] + _trail * _direction;
        break;
      case 6:
        _result = _indi[PPREV].value[LINE_JAW] + _trail * _direction;
        break;
      case 7:
        _result = _indi[PPREV].value[LINE_TEETH] + _trail * _direction;
        break;
      case 8:
        _result = _indi[PPREV].value[LINE_LIPS] + _trail * _direction;
        break;
      case 9: {
        int _bar_count1 = (int)_level * (int)_indi.GetLipsPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count1))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count1));
        break;
      }
      case 10: {
        int _bar_count2 = (int)_level * (int)_indi.GetTeethShift();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count2))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count2));
        break;
      }
      case 11: {
        int _bar_count3 = (int)_level * (int)_indi.GetJawPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count3))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count3));
        break;
      }
    }
    return (float)_result;
  }
};
