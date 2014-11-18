# encoding: UTF-8
#
# Cookbook Name:: websphere
# Attributes:: default
#

# User and Group name under which the server will be installed and running.
default[:websphere][:user] = 'was'
default[:websphere][:group] = 'was'

# ========================== Installation Directories ==========================
#
# The root directory where to install WebSphere Application Server (was)
default[:websphere][:was_install_root] = '/opt/ibm/websphere/appserver'

# The root directory where to install the IBM HTTPD Server (ihs)
default[:websphere][:ihs_install_root] = '/opt/ibm/websphere/ihs'

# The root directory where we will install plugins.
default[:websphere][:plugin_install_root] = '/opt/ibm/websphere/plugins'

# The root directory where we will install Installation Manager (iim)
default[:websphere][:iim_install_root] = '/opt/ibm/iim'

# ================================= Media Paths ================================
#
# Where to unzip installation files.
default[:websphere][:binairy_directory]   = '/opt/ibm/was85nd'

# Garbage collect the zip files?
default[:websphere][:prune_zipfiles] = true

# Garbage collect iim files from node[:websphere][:binairy_directory]?
default[:websphere][:iim][:prune_after_install] = true

# Garbage collect was files from node[:websphere][:binairy_directory]?
default[:websphere][:was][:prune_after_install] = true

# Garbage collect suppl files from node[:websphere][:binairy_directory]?
default[:websphere][:suppl][:prune_after_install] = true

# Garbage collect sdk files from node[:websphere][:binairy_directory]?
default[:websphere][:sdk][:prune_after_install] = true

# ============================= Download Repository ============================
#
# Location of where the zip files should be downloaded.
default[:websphere][:repository_url] = 'http://repo.mudbox.dev/ibm'

# Checksums are calculated with: shasum -a 256 /path/to/file | cut -c-12

# Install IBM Installation Manager (iim)
default[:websphere][:iim][:install] = true
default[:websphere][:iim][:files] = [
  { name: 'InstalMgr1.5.2_LNX_X86_WAS_8.5.zip', checksum: 'd5e652fac67d' }]

# Install WebSphere Network Deployment (was)
default[:websphere][:was][:install] = true
default[:websphere][:was][:files] = [
  { name: 'WAS_ND_V8.5_1_OF_3.zip', checksum: '507777d75ec7' },
  { name: 'WAS_ND_V8.5_2_OF_3.zip', checksum: '4ce6f4be42dd' },
  { name: 'WAS_ND_V8.5_3_OF_3.zip', checksum: '22de0d24e239' }]

# Install WebSphere Supplements (suppl)
default[:websphere][:suppl][:install] = true
default[:websphere][:suppl][:files] = [
  { name: 'WAS_V85_SUPPL_1_OF_3.zip', checksum: '366f8048024a' },
  { name: 'WAS_V85_SUPPL_2_OF_3.zip', checksum: '4cfb708b7a0c' },
  { name: 'WAS_V85_SUPPL_3_OF_3.zip', checksum: 'ccd68201112c' }]

# Install WebSphere Supplements (suppl)
default[:websphere][:sdk][:install] = true
default[:websphere][:sdk][:files] = [
  { name: 'WS_SDK_JAVA_TEV7.0_1OF3_WAS_8.5.zip', checksum: '46f41a6164fa' },
  { name: 'WS_SDK_JAVA_TEV7.0_2OF3_WAS_8.5.zip', checksum: 'a70c63611418' },
  { name: 'WS_SDK_JAVA_TEV7.0_3OF3_WAS_8.5.zip', checksum: '215ce1e438b7' }]
