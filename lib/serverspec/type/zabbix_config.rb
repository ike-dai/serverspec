module Serverspec::Type
  class ZabbixConfig < Base
    require "zabbixapi"

    def initialize name
      @name = name
     
      @zbx = ZabbixApi.connect(
        :url => ENV['ZABBIX_URL'],
        :user => ENV['ZABBIX_USER'],
        :password => ENV['ZABBIX_PASS']
      )
    end

    def host?
      host_id = @zbx.hosts.get_id(:host => @name)
      if host_id then
        return true
      else
        return false
      end
    end

    def template_list
      template_ids = @zbx.templates.get_ids_by_host( :hostids => [@zbx.hosts.get_id(:host => @name)] )
      templates = @zbx.query(
        :method => "template.get",
        :params => {:templateids => template_ids}
      )
      if templates.empty?
        return []
      else
        return templates.map { |t| t["host"] }
      end
    end

    def has_template?(template)
      template_ids = @zbx.templates.get_ids_by_host( :hostids => [@zbx.hosts.get_id(:host => @name)] )
      templates = @zbx.query(
        :method => "template.get",
        :params => {:templateids => template_ids}
      )
      templates.each{ |t|
        if template == t["host"]
          return true
        end
      }
      return false
    end

    def has_interface?(interface)
      hosts = @zbx.query(
        :method => "host.get",
        :params => {:filter => {:host => @name}, :selectInterfaces => "extend"}
      )
      interfaces = hosts[0]["interfaces"]
      interfaces.each { |i|
        if i["ip"] == interface[:ip]
          return true
        end
      }
      return false
    end

    def has_macro?(macros)
      hosts = @zbx.query(
        :method => "host.get",
        :params => {:filter => {:host => @name}, :selectMacros => "extend"}
      )
      macros.each { |key, value|
        flag = false 
        hosts[0]["macros"].each { |m|
          if m["macro"] == key
            if m["value"] != value
              return false
            else
              flag = true
              break
            end
          end
        } 
        if !flag
          return false
        end
        flag = true
      }  
      return true
    end 

    def has_trigger?(trigger)
      triggers = @zbx.query(
        :method => "trigger.get",
        :params => {:host => @name, :expandExpression => true}
      )
      triggers.each { |t|
        if t["expression"] == trigger[:expression]
          return true
        end
      }
      return false
    end

    def valid?
      hosts = @zbx.query(
        :method => "host.get",
        :params => {:filter => {:host => @name}}
      )
      #print hosts
      if hosts[0]["status"] == "0"
        return true
      end
      return false
    end

    def all_item_state
      items = @zbx.query(
        :method => "item.get",
        :params => {:host => @name}
      )
      return items.map { |i| i["state"] == "0" ? "normal" : "not supported" }
    end

    def all_item_status
      items = @zbx.query(
        :method => "item.get",
        :params => {:host => @name}
      )
      return items.map { |i| i["status"] == "0" ? "enabled" : "disabled" }
    end

    def item_state
      @target = :item
      return self
    end

    def normal?(itemkey)
      items = @zbx.query(
        :method => "item.get",
        :params => {:host => @name,:filter => {:key_ => itemkey}}
      )
      if items[0]["state"] == "0"
        return true
      else
        return false
      end
    end

    def enabled?(itemkey)
      items = @zbx.query(
        :method => "item.get",
        :params => {:host => @name,:filter => {:key_ => itemkey}}
      )
      if items[0]["status"] == "0"
        return true
      else
        return false
      end
    end

    def valid_item?(itemkey)
      if itemkey
        items = @zbx.query(
          :method => "item.get",
          :params => {:host => @name,:filter => {:key_ => itemkey}}
        )
        if items[0]["status"] == "0" && items[0]["state"] == "0"
          return true
        else
          return false
        end
      else 
        items = @zbx.query(
          :method => "item.get",
          :params => {:host => @name}
        )
        items.each { |item|
          if item["status"] == "0" && item["state"] == "0"
            continue
          else
            return false
          end
        }
        return true
      end
    end
  end
end

include Serverspec::Type
