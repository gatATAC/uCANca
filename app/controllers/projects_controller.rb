class ProjectsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  auto_actions_for :owner, [:new, :create]

  show_action :gen_code
  show_action :show_structure
  show_action :show_structure_define
  show_action :show_calibration
  show_action :show_calibration_extern
  show_action :show_autodiag_main
  show_action :show_autodiag_main_c
  show_action :show_autodiag_main_functions
  show_action :show_autodiag_main_functions_c
  show_action :show_diagmux_call
  show_action :show_sendmessage
  show_action :show_dtc_a2l
  show_action :show_dtc_code
  show_action :show_diagmux
  show_action :show_diagmux_c
  show_action :show_data_a2l
  show_action :show_data_code
  show_action :show_dataset_spec
  show_action :show_parameter_set
  show_action :show_uds_rdi
  show_action :show_uds_wdi
  show_action :show_uds_sub_services
  show_action :show_uds_serv_fixparams
  show_action :show_uds_services
  show_action :show_uds_routine_ctrls
  show_action :show_uds_ioctl
  show_action :show_uds_bl_rdi
  show_action :show_uds_bl_wdi
  show_action :show_uds_bl_sub_services
  show_action :show_uds_bl_serv_fixparams
  show_action :show_uds_bl_services
  show_action :show_uds_bl_routine_ctrls
  show_action :show_uds_bl_ioctl
  
  def update
    hobo_update do
      respond_to do |format|
        format.js { hobo_ajax_response }
        format.html { redirect_to @project }
      end
    end
  end  
  
  def new
    hobo_new do
      @this.owner=current_user
    end
  end

  def gen_code
    @project=find_instance
    respond_to do |format|
      format.c
      format.h
      format.xcos
      format.cdp
      format.iox
      format.iocsv
      format.ioxls
      format.a2l
      format.csv
      format.par
    end
  end

  def show
    @project=find_instance
    respond_to do |format|
      format.html {
        @flows=find_instance.flows.search(params[:search], :name).order_by(parse_sort_param(:name, :flow_type)).paginate(:page => params[:page])
        if (params[:flow_type]) then
          if (params[:flow_type]!="") then
            @flows = @flows.flow_type_is(params[:flow_type])
          end
        end
        @sub_systems=find_instance.sub_systems
        @fault_requirements=find_instance.fault_requirements
        @fail_safe_commands=find_instance.fail_safe_commands
        @fail_safe_command_times=find_instance.fail_safe_command_times
        @fault_detection_moments=find_instance.fault_detection_moments        
        @fault_preconditions=find_instance.fault_preconditions      
        @fault_rehabilitations=find_instance.fault_rehabilitations      
        @fault_recurrence_times=find_instance.fault_recurrence_times       
=begin
    @functions=Function.search(params[:search_func], :name).order_by(parse_sort_param(:name, :function_type)).paginate(:page => params[:page])
    if (params[:function_type]) then
      if (params[:function_type]!="") then
        @functions = @functions.function_type_is(params[:function_type])
      end
    end
=end
        hobo_show do
          if params[:style]
            send_file @project.logo.path(params[:style])
          else
            render
          end
        end
      }
    end
  end

  def show_calibration
    @code=""

    find_instance.fault_recurrence_times.find(:all).each { |r|
      @code+=r.to_calibration
    }
  end

  def show_calibration_extern
    @code = ""
    contador=0
    find_instance.fault_requirements.find(:all).each{|fr|
      fr.faults.find(:all).each { |r|
        @code+="#define DTC_"+r.dtc_prefix+r.dtc+" "+contador.to_s+"\n"
        contador=contador+1
      }}

    @code+="\ntypedef struct {\n"
    @code+="\tuint16_t ident;\n"
    @code+="\tuint8_t low_byte;\n"
    @code+="}t_dtc;\n\n"
    @code+="#define DTC_NUM "+contador.to_s+"\n\n"
    @code+="extern t_dtc dtc[DTC_NUM];\n\n"
    find_instance.fault_recurrence_times.find(:all).each { |r|
      @code+=r.to_calibration_extern
    }
  end

  def show_structure
    @code = ""
    find_instance.fail_safe_commands.find(:all).each { |r|
      @code+=r.to_structure
    }
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_structure
    }
  end

  def show_structure_define
    @code = ""

    find_instance.fail_safe_commands.find(:all).each { |r|
      @code+=r.to_structure_define
    }
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_structure_define
    }
  end

  def show_autodiag_main
    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_autodiag_main
    }
  end

  def show_autodiag_main_c

    @code = "void AD_FailSafeCommands_clear(){\n"
    find_instance.fail_safe_commands.find(:all).each { |i|
      @code+=i.to_autodiag_main_c
    }
    @code += "}\n\n"

    @code += "void AD_FailSafeCommands_decrement(){\n"
    find_instance.fail_safe_commands.find(:all).each { |i|
      @code+=i.to_autodiag_main_c_decrement
    }
    @code += "}\n"

    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_autodiag_main_c
    }
    @code+="\n"

  end

  def show_uds_rdi
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="22" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_rdi_c(index)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        @code_mem=""
        @code_decl=""
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="22" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetmem,coderetdecl=si.to_rdi_h(prev_instance)
                  @code += coderet
                  @code += "\n"                
                  @code_mem += coderetmem
                  @code_mem += "\n"
                  @code_decl += coderetdecl
                  index += 1
                  prev_instance=si
                end
              end
            }
            @number="(UDS_RDI_"+prev_instance.c_define_name+"_INDEX)"
          end
        }
      }
    end
    
  end

  def show_uds_wdi
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2E" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_wdi_c(index)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        @code_mem=""
        @code_decl=""
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2E" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetmem,coderetdecl=si.to_wdi_h(prev_instance)
                  @code += coderet
                  @code += "\n"
                  @code_mem += coderetmem
                  @code_mem += "\n"
                  @code_decl += coderetdecl                  
                  index += 1
                  prev_instance=si
                end
              end
            }
            @number="(UDS_WDI_"+prev_instance.c_define_name+"_INDEX)"
          end
        }
      }
    end
  end

  def show_uds_ioctl
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2F" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_ioctl_c(index)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        @code_mem=""
        @code_func=""
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2F" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetmem,coderetfunc = si.to_ioctl_h(prev_instance)
                  @code += coderet
                  @code += "\n"
                  @code_mem += coderetmem
                  @code_mem += "\n"
                  @code_func += coderetfunc
                  @code_func += "\n"
                  index += 1
                  prev_instance=si
                end
              end
            }
            @number="(UDS_IOCTL_"+prev_instance.c_define_name+"_INDEX)"
          end
        }
      }
    end
    
  end
  
  
  def show_uds_sub_services
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident!="22" && s.ident!="2E" && s.ident!="31") then
            index=0
            s.uds_sub_services.find(:all).each { |si|
              coderet,coderetswitch,codeinit = si.to_sub_serv_c(index)
              index += 1
              @code += coderet
              @code_switch += coderetswitch
              @code_init += codeinit
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident!="22" && s.ident!="2E" && s.ident!="31") then
            index=0
            s.uds_sub_services.find(:all).each { |si|
              @code += si.to_sub_serv_h(prev_instance)
              @code += "\n"
              index += 1
              prev_instance=si
            }
          end
        }
        @number="(UDS_RDI_"+prev_instance.c_define_name+"_INDEX)"
      }
    end
  end

  def show_uds_serv_fixparams
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          # Services with fixed params 
          s.uds_service_fixed_params.find(:all).each { |si|
            if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
              if (si.generate) then
                coderet,coderetswitch,codeinit = si.to_serv_fixparams_c(index)
                index += 1
                if (s.ident!="31") then
                  @code += coderet                  #(except: routine control, ...)
                  @code_switch += coderetswitch     #(except: routine control, ...)
                end
                @code_init += codeinit
              end
            end
          }
          # SubServices with fixed params 
          s.uds_sub_services.find(:all).each {|ss|
            ss.uds_service_fixed_params.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_serv_fixparams_c(index)
                  index += 1
                  if (ss.uds_service.ident!="31") then
                    @code += coderet               #(except: routine control, ...)
                    @code_switch += coderetswitch     #(except: routine control, ...)
                  end
                  @code_init += codeinit
                end
              end
            }
          }
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          s.uds_service_fixed_params.find(:all).each { |si|
            if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
              if (si.generate) then
                @code += si.to_serv_fixparams_h(prev_instance)
                @code += "\n"
                index += 1
                prev_instance=si
              end
            end
          }
        }
        @number="(UDS_SERV_FIXPARAMS_"+prev_instance.complete_c_define_name+"_INDEX)"
      }
    end
  end

  def show_uds_routine_ctrls
    @code = ""
    @code_switch = ""
    @code_init = ""
    @code_func = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          if (s.ident=="31") then
            # SubServices with fixed params
            s.uds_sub_services.find(:all).each {|ss|
              ss.uds_service_fixed_params.find(:all).each { |si|
                if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                  if (si.generate) then
                    coderet,coderetswitch,codeinit = si.to_routine_ctrl_c(index)
                    index += 1
                    @code += coderet
                    @code_switch += coderetswitch
                    @code_init += codeinit
                  end
                end
              }
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident=="31") then
            # SubServices with fixed params
            @number=0
            s.uds_service_fixed_params.find(:all).each { |si|
              if (si.app_session_default or si.app_session_prog or si.app_session_extended or si.app_session_supplier) then
                if (si.generate) then                  
                  coderet,coderetfunc = si.to_routine_ctrl_h(prev_instance)
                  @code += coderet
                  @code_func += coderetfunc
                  @code += "\n"
                  @code_func += "\n"
                  @number += 1
                  prev_instance=si                  
                end
              end
            }
          end
        }
      }
    end
  end

  def show_uds_services
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        index=0
        find_instance.uds_services.find(:all).each { |s| 
          #         if s.uds_sub_services.size==0 then
          #           if s.uds_service_fixed_params.size==0 then
          #             if s.uds_service_identifiers.size==0 then
          if (s.app_session_default or s.app_session_prog or s.app_session_extended or s.app_session_supplier) then
            if (s.generate) then
              coderet,coderetswitch,codeinit = s.to_serv_c(index)
              index += 1
              @code += coderet
              @code_switch += coderetswitch
              @code_init += codeinit
            end
          end
          #             end
          #           end
          #         end
        }
        @number=index
      }
        
      format.h { 
        @code_mem=""
        prev_instance=nil
        index=0
        find_instance.uds_services.find(:all).each { |s| 
          if (s.app_session_default or s.app_session_prog or s.app_session_extended or s.app_session_supplier) then
            if (s.generate) then
              #             if s.uds_sub_services.size==0 then
              #               if s.uds_service_fixed_params.size==0 then
              #                 if s.uds_service_identifiers.size==0 then
              coderet,coderetmem=s.to_serv_h(prev_instance)
              @code += coderet
              @code += "\n"                
              @code_mem += coderetmem
              @code_mem += "\n"
              index += 1
              prev_instance=s
              #                 end
              #               end
              #             end
            end
          end
        }
        @number="(UDS_"+prev_instance.c_define_name+"_INDEX)"
      }
    end
    
  end




  
  def show_autodiag_main_functions
    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_autodiag_main_functions
    }
  end

  def show_autodiag_main_functions_c

    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_autodiag_main_functions_c
    }
    @code+="\n"

  end

  def show_diagmux
    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_diagmux
    }
  end

  def show_diagmux_c
    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_diagmux_c
    }
    @code+="\n"

  end

  def show_diagmux_call
    @code = ""

    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_diagmux_call_init
    }
    @code+="}\nvoid AutoDiagnosticsFSM(){\n"
    @code +="\n\tAutoDiagnosticsFSMAux();\n"
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_diagmux_call_normal
    }
    @code+="}\n"
  end

  def show_dtc_a2l
    @code = ""
    contador=0
    find_instance.fault_requirements.find(:all).each{|fr|
      fr.faults.find(:all).each { |r|
        @code+=r.to_dtc_a2l(contador)+"\n"
        contador=contador+1
      }}
    find_instance.fail_safe_commands.find(:all).each { |r|
      @code+=r.to_a2l+"\n"
    }
  end
  
  def show_dtc_code
    @code = "\nBOOL ad_dtcs_valid(void){\n\treturn (TRUE\n"
    find_instance.fault_requirements.find(:all).each{|fr|
      fr.faults.find(:all).each { |r|
        @code+="\t\t&& "+r.to_dtc_code_valid+"\n"
      }}
    @code+="\t\t);\n}\n"
    @code+="\nvoid ad_init_dtcs(void) {\n\tif (ad_dtcs_valid() == FALSE) {\n"
    find_instance.fault_requirements.find(:all).each{|fr|
      fr.faults.find(:all).each { |r|
        @code+="\t\t"+r.to_dtc_code_init+"\n"
      }}
    @code+="\t\tad_clear_dtcs();\n\t} else {\n\t\tad_decrement_dtcs();\n\t}\n}\n"
  end

  def show_sendmessage
    @code = ""
    find_instance.fault_requirements.find(:all).each { |r|
      @code+=r.to_sendmessage
    }
  end

  def show_data_a2l
    @code =""
    FlowType.find(:all).each {|dt|
      @code+=dt.to_a2l+"\n"
    }
    find_instance.datum_conversions.find(:all).each { |d|
      @code+=d.to_a2l+"\n"
    }
    @code+="\n"
    find_instance.flows.each { |f|
      f.data.each {|r|
        if (r.generate) then
          r.datum_datum_conversions.find(:all).each { |d|
            @code+=d.to_a2l+"\n"
          }
        end
      }
    }
    return @code
  end
  
  def show_data_code
    @code="/**** AutoDiagnostics_calibration.h ****/\n"
    find_instance.flows.each { |f|
      f.data.each {|r|
        if (r.generate) then
          r.datum_datum_conversions.find(:all).each { |d|
            @code+=d.to_code_declaration;
          }
        end
      }
    }
    @code+="\n\n/**** AutoDiagnostics_calibration.c ****/\n"
    find_instance.flows.each { |f|
      f.data.each {|r|
        if (r.generate) then
          r.datum_datum_conversions.find(:all).each { |d|
            @code+=d.to_code
          }
        end
      }
    }
    return @code
  end
  
  def show_dataset_spec
    @code="Calibration list for AutoDiagnostics;;;;;;;;;;\n"
    @code+="Name;Parameter description;AutoSar Compliant;Min value;Max value;Typ value;Special vector;Unit;Data type;Size data;Resolution\n"
    find_instance.flows.each { |f|
      f.data.each {|r|
        if (r.generate) then
          r.datum_datum_conversions.find(:all).each { |d|
            @code+=d.to_dataset_spec+"\n"
          }
        end
      }
    }
    return @code
  end
  def show_parameter_set
    @code="CANape PAR V3.1: INE_HONDA_DCU.a2l 1 0 CCP_DCU\n"
    @code+=";Parameter file created by DRE code generator\n;\n"
    find_instance.flows.each { |f|
      f.data.each {|r|
        if (r.generate) then
          r.datum_datum_conversions.find(:all).each { |d|
            @code+=d.to_parameter_set+"\n"
          }
        end
      }
    }
    return @code
  end



  def show_uds_bl_rdi
    @code = ""
    @code_mem = ""
    @code_switch = ""
    @code_init = ""
    @code_func = ""
    @code_redirect = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="22" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_rdi_c(index,true)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="22" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  code,coderetmem,coderetfunc,coderetredirect = si.to_rdi_h(prev_instance,true)
                  @code += code
                  @code += "\n"
                  @code_mem += coderetmem
                  @code_mem += "\n"
                  @code_func += coderetfunc
                  @code_func += "\n"
                  @code_redirect += coderetredirect
                  @code_redirect += "\n"
                  index += 1
                  prev_instance=si
                end
              end
            }
            @number="(UDS_RDI_"+prev_instance.c_define_name+"_INDEX)"
          end
        }
      }
    end
    
  end

  def show_uds_bl_wdi
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2E" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_wdi_c(index,true)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        @code_mem=""
        @code_decl=""
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2E" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetmem,coderetdecl=si.to_wdi_h(prev_instance,true)
                  @code += coderet
                  @code += "\n"
                  @code_mem += coderetmem
                  @code_mem += "\n"
                  @code_decl += coderetdecl                  
                  index += 1
                  prev_instance=si
                end
              end
            }
            @number="(UDS_WDI_"+prev_instance.c_define_name+"_INDEX)"
          end
        }
      }
    end
  end

  def show_uds_bl_ioctl
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2F" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_ioctl_c(index,true)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if s.ident=="2F" then
            index=0
            s.uds_service_identifiers.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  @code += si.to_ioctl_h(prev_instance,true)
                  @code += "\n"
                  index += 1
                  prev_instance=si
                end
              end
            }
            if (prev_instance) then
              @number="(UDS_IOCTL_"+prev_instance.c_define_name+"_INDEX)"
            else 
              @number="(0)  /* No IOCTL */"
            end            
          end
        }
      }
    end
    
  end
  
  
  def show_uds_bl_sub_services
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident!="22" && s.ident!="2E" && s.ident!="31") then
            index=0
            s.uds_sub_services.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_sub_serv_c(index,true)
                  index += 1
                  @code += coderet
                  @code_switch += coderetswitch
                  @code_init += codeinit
                end
              end
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident!="22" && s.ident!="2E" && s.ident!="31") then
            index=0
            s.uds_sub_services.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  @code += si.to_sub_serv_h(prev_instance,true)
                  @code += "\n"
                  index += 1
                  prev_instance=si
                end
              end
            }
          end
        }
        @number="(UDS_RDI_"+prev_instance.c_define_name+"_INDEX)"
      }
    end
  end

  def show_uds_bl_serv_fixparams
    @code = ""
    @code_switch = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          # Services with fixed params 
          s.uds_service_fixed_params.find(:all).each { |si|
            if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
              if (si.generate) then
                coderet,coderetswitch,codeinit = si.to_serv_fixparams_c(index,true)
                index += 1
                if (s.ident!="31") then
                  @code += coderet                  #(except: routine control, ...)
                  @code_switch += coderetswitch     #(except: routine control, ...)
                end
                @code_init += codeinit
              end
            end
          }
          # SubServices with fixed params 
          s.uds_sub_services.find(:all).each {|ss|
            ss.uds_service_fixed_params.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetswitch,codeinit = si.to_serv_fixparams_c(index,true)
                  index += 1
                  if (ss.uds_service.ident!="31") then
                    @code += coderet               #(except: routine control, ...)
                    @code_switch += coderetswitch     #(except: routine control, ...)
                  end
                  @code_init += codeinit
                end
              end
            }
          }
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          s.uds_service_fixed_params.find(:all).each { |si|
            if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
              if (si.generate) then
                @code += si.to_serv_fixparams_h(prev_instance,true)
                @code += "\n"
                index += 1
                prev_instance=si
              end
            end
          }
        }
        if prev_instance then
          @number="(UDS_SERV_FIXPARAMS_"+prev_instance.complete_c_define_name+"_INDEX)"
        else
          @number="(0)"
        end
      }
    end
  end

  def show_uds_bl_routine_ctrls
    @code = ""
    @code_switch = ""
    @code_init = ""
    @code_func = ""
    respond_to do |format|
      format.c {
        find_instance.uds_services.find(:all).each { |s| 
          index=0
          if (s.ident=="31") then
            # SubServices with fixed params
            s.uds_sub_services.find(:all).each {|ss|
              ss.uds_service_fixed_params.find(:all).each { |si|
                if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                  if (si.generate) then
                    coderet,coderetswitch,codeinit = si.to_routine_ctrl_c(index,true)
                    index += 1
                    @code += coderet
                    @code_switch += coderetswitch
                    @code_init += codeinit
                  end
                end
              }
            }
          end
        }
      }
      format.h {
        prev_instance=nil
        find_instance.uds_services.find(:all).each { |s| 
          if (s.ident=="31") then
            # SubServices with fixed params
            @number=0
            s.uds_service_fixed_params.find(:all).each { |si|
              if (si.boot_session_default or si.boot_session_prog or si.boot_session_extended or si.boot_session_supplier) then
                if (si.generate) then
                  coderet,coderetfunc = si.to_routine_ctrl_h(prev_instance,true)
                  @code += coderet
                  @code += "\n"
                  @code_func += coderetfunc
                  @code_func += "\n"
                  @number += 1
                  prev_instance=si                  
                end
              end
            }
          end
        }
      }
    end
  end

  def show_uds_bl_services
    @code = ""
    @code_switch = ""
    @code_def = ""
    @code_mem = ""
    @code_init = ""
    respond_to do |format|
      format.c {
        index=0
        find_instance.uds_services.find(:all).each { |s| 
          if s.uds_sub_services.size==0 then
            if s.uds_service_fixed_params.size==0 then
              if s.uds_service_identifiers.size==0 then
                if (s.boot_session_default or s.boot_session_prog or s.boot_session_extended or s.boot_session_supplier) then
                  if (s.generate) then
                    coderet,coderetswitch,codeinit = s.to_serv_c(index,true)
                    index+=1
                    @code += coderet
                    @code_switch += coderetswitch
                    @code_init += codeinit
                  end
                end
              end
            end
          end
        }
        @number=index
      }
        
      format.h { 
        prev_instance=nil
        index=0
        find_instance.uds_services.find(:all).each { |s| 
          if (s.boot_session_default or s.boot_session_prog or s.boot_session_extended or s.boot_session_supplier) then
            if (s.generate) then
              if s.uds_sub_services.size==0 then
                if s.uds_service_fixed_params.size==0 then
                  if s.uds_service_identifiers.size==0 then
                    coderet,coderetmem = s.to_serv_h(prev_instance,true)
                    @code += coderet
                    @code += "\n"
                    index += 1
                    prev_instance=s
                  end
                end
              end
            end
          end
        }
        if (prev_instance) then
          @number="(UDS_SERV_"+prev_instance.c_define_name+"_INDEX)"
        else 
          @number="(0)  /* No services */"
        end
      }
    end
    
  end

end
