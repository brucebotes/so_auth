server '52.26.245.112', user: 'admin', roles: %w{app db web}, primary: true
set :ssh_options, {
   port: 22,
   forward_agent: true,
   #keys: %w(/Volumes/Macintosh2/Users/brucebotes/.ssh/id_rsa)
   keys: %w(/home/bruce/.ssh/EC2_twighorse.pem)
 }
