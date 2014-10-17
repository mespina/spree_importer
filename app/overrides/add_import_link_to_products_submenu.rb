Deface::Override.new( :virtual_path  => "spree/admin/shared/_product_sub_menu",
                      :insert_bottom => "[data-hook='admin_product_sub_tabs']",
                      :text          => "<%= tab :import, :route => 'admin_importer_index'%>",
                      :name          => "add_import_link_to_product_submemu.rb")
