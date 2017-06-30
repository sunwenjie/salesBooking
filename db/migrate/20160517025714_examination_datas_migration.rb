class ExaminationDatasMigration < ActiveRecord::Migration
  def change

   # 迁移orders表字段(排期表提交时间，排期表提交人，GP分配时间，GP提交人，是否是非标订单，是否能分配GP，是否有地是分配，gp是否分配完成)
    Order.all.each_with_index { |o,index |
      gp_commit_user = ""
      gp_commit_time = nil
      schedule_commit_user = ""
      schedule_commit_time = nil

      p "***************update_order_columns*********"
      is_standard = o.order_standard_or_unstandard? ? true : false
      have_admeasure_map = o.order_have_admeasure_map? ? true : false
      is_jast_for_gp =  o.jast_for_gp_advertisement? ? true : false
      is_gp_finish,is_gp_commit = (o.jast_for_gp_advertisement? && o.any_not_order_gp_finish?) ? [true,true] : [false,false]

      if o.jast_for_gp_advertisement? && o.all_order_gp_finish?
        examination = Examination.where({"examinable_id"=>o.id,"examinable_type"=>"Order","from_state"=>"planner_unapproved","to_state"=>"planner_approved"})
        if examination.present?
        examination_last = examination.last
        gp_commit_user = examination_last.created_user
        gp_commit_time = examination_last.created_at
        end
      end
    examination_proof = Examination.where({"examinable_id"=>o.id,"examinable_type"=>"Order","to_state"=>"proof_unapproved"})
    if examination_proof.present?
    examination_proof_last = examination_proof.last
    schedule_commit_user = examination_proof_last.created_user
    schedule_commit_time = examination_proof_last.created_at
    end
    o.update_columns(:is_standard=>is_standard,:have_admeasure_map=>have_admeasure_map,:is_jast_for_gp=>is_jast_for_gp,:is_gp_finish=>is_gp_finish,:gp_commit_user=>gp_commit_user,:gp_commit_time=>gp_commit_time,:schedule_commit_user=>schedule_commit_user,:schedule_commit_time=>schedule_commit_time,:is_gp_commit=>is_gp_commit)

      #运营已分配
      last_operations = o.operations.last   if  o.operations.present?
      if last_operations.present?
        examinable_new_order_distribute = Examination.new
        examinable_new_order_distribute.approval  = "1"
        examinable_new_order_distribute.comment = last_operations.comment
        examinable_new_order_distribute.examinable_id = o.id
        examinable_new_order_distribute.examinable_type = "Order"
        examinable_new_order_distribute.node_id = 5
        examinable_new_order_distribute.status = "2"
        examinable_new_order_distribute.created_at = last_operations.created_at
        examinable_new_order_distribute.save(:validate=>false)
      end

    p "************index:"+index.to_s
    }


    #迁移examination历史数据
    #订单
    examinations = Examination.where("node_id is null and status is null and examinable_type = 'Order' ")
    examinations.each_with_index{|examinable,index|
      p "************order_index:#{index},examinable_id:#{examinable.examinable_id}"
      order = (Order.find_by_sql ("select * from orders where id = #{examinable.examinable_id}")).first

      #售前提交
      if examinable.to_state == "planner_unapproved"
        p 1111111111111
        examinable.node_id = 1
        examinable.status = "1"
      end
      #售前审批通过
      if  examinable.to_state == "planner_approved"
        p 2222222222
        examinable.node_id = 1
        examinable.status = "2"
      end
      if  examinable.from_state == "planner_unapproved" && examinable.to_state == "sales_president_unapproved"
        p 3333333333
        new_attr = examinable.attributes
        new_attr.delete("id")

        examinable_new_pre_approval = Examination.create(new_attr)
        examinable_new_pre_approval.from_state = "planner_unapproved"
        examinable_new_pre_approval.to_state = "planner_approved"
        examinable_new_pre_approval.node_id = 1
        examinable_new_pre_approval.status = "2"
        examinable_new_pre_approval.save()

        examinable_new_order_submit = Examination.create(new_attr)
        examinable_new_pre_approval.from_state = "planner_approved"
        examinable_new_pre_approval.to_state = "sales_president_unapproved"
        examinable_new_order_submit.node_id = 3
        examinable_new_order_submit.status = "1"
        examinable_new_order_submit.save()
      end


      if  examinable.from_state == "order_saved" && examinable.to_state == "sales_president_unapproved"
        new_attr = examinable.attributes
        new_attr.delete("id")
        examinable_new_pre_approval = Examination.create(new_attr)
        examinable_new_pre_approval.from_state = "order_saved"
        examinable_new_pre_approval.to_state = "sales_president_unapproved"
        examinable_new_pre_approval.node_id = 3
        examinable_new_pre_approval.status = "1"
        examinable_new_pre_approval.save()
      end



      #订单提交
      if examinable.to_state == "sales_manager_unapproved" ||  examinable.to_state == "product_assessing_officer_unapproved" || (examinable.from_state == "planner_approved" && examinable.to_state == "sales_president_unapproved")
         p 444444444444
         if order.is_standard
           examinable.node_id = 3
         else
           examinable.node_id = 2
         end

        examinable.status = "1"
      end

      #订单审批通过
      if examinable.from_state != "examine_completed" && examinable.to_state == "proof_ready"
        p 55555555555555
        if order.is_standard
          examinable.node_id = 3
        else
          examinable.node_id = 2
        end
        examinable.status = "2"
      end
      #订单审批不通过
      if (examinable.from_state == "sales_manager_unapproved" || examinable.from_state == "sales_president_unapproved" ) && examinable.to_state == "rejected"
        p 666666666666
        if order.is_standard
          examinable.node_id = 3
        else
          examinable.node_id = 2
        end
        examinable.status = "3"
      end

      #合同审批环节提交
      if examinable.to_state == "legal_officer_unapproved"
        p 77777777777777
        examinable.node_id = 4
        examinable.status = "1"
      end

      if examinable.from_state == "proof_unapproved" && examinable.to_state == "examine_completed"
        p 8888888888888888
        new_attr = examinable.attributes
        new_attr.delete("id")

        examinable_new_contract_submit = Examination.create(new_attr)
        examinable_new_contract_submit.node_id = 4
        examinable_new_contract_submit.status = "1"
        examinable_new_contract_submit.save()

        examinable_new_contract_approval = Examination.create(new_attr)
        examinable_new_contract_approval.node_id = 4
        examinable_new_contract_approval.status = "2"
        examinable_new_contract_approval.save()

      end

      #合同审批通过
      if examinable.from_state == "legal_officer_unapproved" && examinable.to_state == "examine_completed"
        p 9999999999999999
        examinable.node_id = 4
        examinable.status = "2"
      end

      #合同审批不通过
      if examinable.from_state == "legal_officer_unapproved" && examinable.to_state == "rejected"
        p 1110000000000000000
        examinable.node_id = 4
        examinable.status = "3"
      end

      examinable.save()
    }

    #客户
    client_examinations = Examination.where("node_id is null and status is null and examinable_type = 'Client' ")
    client_examinations.each_with_index { |examinable, index|
      p "**********client_index:#{index}"
      examinable.node_id = 6
      #客户提交
      if examinable.to_state == "unapproved"
        examinable.status = "1"
      end
      #客户审批通过
      if examinable.from_state == "unapproved" && examinable.to_state == "approved"
        examinable.status = "2"
      end

      #客户审批不通过
      if  examinable.to_state == "cli_rejected"
        examinable.status = "3"
      end

      #客户释放
      if  examinable.to_state == "released"
        examinable.status = "4"
      end

      #抢客户
      if examinable.from_state == "cli_saved" && examinable.to_state == "approved"
        new_attr = examinable.attributes
        new_attr.delete("id")

        examinable_new_client_submit = Examination.create(new_attr)
        examinable_new_client_submit.from_state = "cli_saved"
        examinable_new_client_submit.to_state = "unapproved"
        examinable_new_client_submit.node_id = 6
        examinable_new_client_submit.status = "1"
        examinable_new_client_submit.save()

        examinable_new_client_approval = Examination.create(new_attr)
        examinable_new_client_approval.from_state = "unapproved"
        examinable_new_client_approval.to_state = "approved"
        examinable_new_client_approval.node_id = 6
        examinable_new_client_approval.status = "2"
        examinable_new_client_approval.save()
      end
      examinable.save()
    }

  end



end
