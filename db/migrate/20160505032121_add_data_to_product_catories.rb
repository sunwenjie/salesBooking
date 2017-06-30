class AddDataToProductCatories < ActiveRecord::Migration
  def change
    ProductCategory.create [
                            {name: 'Mobile DSP',en_name: 'Mobile DSP',value: 'Mobile DSP'},
                            {name: 'MoFeeds',en_name: 'MoFeeds',value: 'MoFeeds'},
                            {name: 'Mofeeds+Banner混投',en_name: 'Mofeeds+Banner Mix',value: 'Mofeeds+Banner混投'},
                            {name: 'MoSocial',en_name: 'MoSocial',value: 'MoSocial'},
                            {name: 'MOTV Open Splash',en_name: 'MOTV Open Splash',value: 'MOTV Open Splash'},
                            {name: 'MOTV in-feeds',en_name: 'MOTV in-feeds',value: 'MOTV in-feeds'},
                            {name: 'MOTV Mix',en_name: 'MOTV Mix',value: 'MOTV Mix'},
                            {name: 'Mobile-OTV(15s)',en_name: 'Mobile-OTV(15s)',value: 'Mobile-OTV(15s)'},
                            {name: 'Mobile-OTV(30s)',en_name: 'Mobile-OTV(30s)',value: 'Mobile-OTV(30s)'},
                            {name: 'PC DSP',en_name: 'PC DSP',value: 'PC DSP'},
                            {name: 'PC-Richmedia',en_name: 'PC-Richmedia',value: 'PC-Richmedia'},
                            {name: 'PC-AdTV(15s)',en_name: 'PC-AdTV(15s)',value: 'PC-AdTV(15s)'},
                            {name: 'PC-AdTV(30s)',en_name: 'PC-AdTV(30s)',value: 'PC-AdTV(30s)'},
                            {name: 'PC-OTV(15s)',en_name: 'PC-OTV(15s)',value: 'PC-OTV(15s)'},
                            {name: 'PC-OTV(30s)',en_name: 'PC-OTV(30s)',value: 'PC-OTV(30s)'},
                            {name: 'OptAim-PC平台',en_name: 'OptAim-PC平台',value: 'OptAim-PC平台'},
                            {name: 'OptAim-移动平台',en_name: 'OptAim-移动平台',value: 'OptAim-移动平台'}
                           ]
  end
end
