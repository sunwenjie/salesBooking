class MediaList < ActiveRecord::Base
  INTEREST = {"高档汽车" => [], "中档汽车" => [], "入门级汽车" => [], "二手车" => [], "汽车租赁" => [], "豪华汽车" => [], "汽车保险" => [], "日本韩国车" => [], "德国车" => [], "美国车" => [], "国产车" => [], "三厢车" => [], "轿跑车" => [], "两厢车" => [], "越野车" => [], "旅行车" => [], "面包车" => [], "敞篷车" => [], "多功能车" => [], "跑车" => [], "护肤" => ["抗衰老去皱", "补水保湿", "美白提亮祛斑", "隔离防晒", "清洁卸妆", "男士护肤", "祛痘", "抗过敏", "眼部护理", "身体护肤"], "彩妆" => ["面部彩妆", "眼部彩妆", "唇部彩妆", "指甲/手部"], "美发护发" => [], "旅游" => ["奢华酒店", "高级酒店", "商务酒店", "经济型酒店", "度假型出租", "北美旅游", "东南亚旅游", "日本 / 韩国旅游", "欧洲旅游", "非洲旅游", "大洋洲旅游 （澳洲 & 新西兰）", "港澳游"], "私立学校" => ["私立幼儿园", "私立小学", "私立中学"], "留学移民" => ["留学考试", "留学申请", "留学移民欧洲", "留学移民北美", "留学移民澳洲", "留学移民日韩", "留学移民港澳新"], "MBA/EMBA" => [], "职业技能培训" => [], "早教幼教" => [], "语言培训" => [], "保险" => ["人寿保险", "健康保险", "财产保险"], "投资理财" => ["个人贷款", "投资和资产管理", "信用卡", "银行零售服务"], "母婴用品" => ["婴幼儿尿裤", "喂养用品", "婴幼奶粉", "幼儿食品", "妈妈用品", "婴幼护理", "童车推车", "汽车安全座椅", "婴儿寝具"], "咨询及服务" => ["婚庆", "招聘求职", "相亲交友"]}
end
