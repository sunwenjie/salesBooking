class ExchangeRate < ActiveRecord::Base
  establish_connection :xmo_production
  self.table_name = "exchange_rates"

  def self.get_rate(currency, base_currency)
    ex_result = ExchangeRate.find_by_sql("SELECT xmo.get_eff_cx_rate('#{base_currency}','#{currency}','2013-11-01')")
    return ex_result[0].present? ? ex_result[0].attributes.except("id").values[0].to_f : 1.0
  end

end