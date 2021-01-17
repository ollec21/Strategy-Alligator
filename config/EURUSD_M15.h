/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_M15 : AlligatorParams {
  Indi_Alligator_Params_M15() : AlligatorParams(indi_alli_defaults, PERIOD_M15) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    ma_method = (ENUM_MA_METHOD)0;
    period_jaw = 4;
    period_lips = 4;
    period_teeth = 4;
    shift = 0;
    shift_jaw = 0;
    shift_lips = 0;
    shift_teeth = 0;
  }
} indi_alli_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_M15 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_M15() : StgParams(stg_alli_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_alli_m15;
