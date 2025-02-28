/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_M1 : AlligatorParams {
  Indi_Alligator_Params_M1() : AlligatorParams(indi_alli_defaults, PERIOD_M1) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    jaw_period = 17;
    jaw_shift = 12;
    lips_period = 9;
    lips_shift = 11;
    ma_method = (ENUM_MA_METHOD)2;
    shift = 0;
    teeth_period = 10;
    teeth_shift = 3;
  }
} indi_alli_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_M1 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_M1() : StgParams(stg_alli_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_alli_m1;
