class AdmeasureMigrate < ActiveRecord::Migration
  def change
    # advertisements = Advertisement.where("admeasure is not null")
    # if advertisements.present?
    #   advertisements.each{|ad|

    #     admeasure = ad.admeasure
    #     admeasure_en = ad.admeasure_en
    #     admeasure_new = []
    #     admeasure_en_new = []
    #     admeasure.each do |admeasure|
    #       admeasure_new << [admeasure[0],admeasure[1].blank? ? admeasure[1] : (admeasure[1].to_f/100 * ad.budget_ratio("super"))]
    #     end

    #     admeasure_en.each do |admeasure_en|
    #       admeasure_en_new << [admeasure_en[0],admeasure_en[1].blank? ? admeasure_en[1] : (admeasure_en[1].to_f/100 * ad.budget_ratio("super"))]
    #     end

    #      ad.update_columns({:admeasure=>admeasure_new, :admeasure_en=> admeasure_en_new})
    #   }
    # end
  end
end
