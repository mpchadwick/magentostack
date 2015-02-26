# Install preparation involves lots of variable calculation, most of which is
# then placed in `node.run_state['magentostack_installer_...']`

# flag for an installer or setup having been done already
node.run_state['magentostack_installer_magento_configured_file'] = "#{node['magentostack']['web']['dir']}/.magento_configured"

# determine plain URL
http_port = node['magentostack']['web']['http_port']
url = if http_port == 80
        "http://#{node['magentostack']['web']['domain']}/"
      else
        "http://#{node['magentostack']['web']['domain']}:#{http_port}/"
      end
node.default['magentostack']['config']['url'] = url

# determine URL with SSL enabled
https_port = node['magentostack']['web']['https_port']
secure_base_url = if https_port == 443
                    "https://#{node['magentostack']['web']['domain']}/"
                  else
                    "https://#{node['magentostack']['web']['domain']}:#{https_port}/"
                  end
node.default['magentostack']['config']['secure_base_url'] = secure_base_url

# Configure all the database things
include_recipe 'magentostack::_find_mysql'
node.run_state['magentostack_installer_database_name'] = node['magentostack']['mysql']['databases'].keys[0]
dbh = node['magentostack']['config']['db']['host']
dbp = node['magentostack']['config']['db']['port']

node.run_state['magentostack_installer_database_host'] = if dbh && dbp
                                                           "#{dbh}:#{dbp}"
                                                         elsif dbh
                                                           dbh
                                                         else
                                                           false
                                                         end
database_name = node.run_state['magentostack_installer_database_name']
node.run_state['magentostack_installer_database_user'] = node['magentostack']['mysql']['databases'][database_name]['mysql_user']
node.run_state['magentostack_installer_database_pass'] = node['magentostack']['mysql']['databases'][database_name]['mysql_password']