
#Download SQL docker:
sudo docker pull microsoft/mssql-server-linux:2017-latest

#Check existing dockers:
docker ps -a

#Sql Docker start when image doesn't exists - i.e. create new container with name sql_VR_1:
sudo docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=HarfordSteam1!' \
   -p 4433:1433 --name sql_VR_1 \
   -d microsoft/mssql-server-linux:2017-latest

 #If image exists but container is not running -> Start it:
 #Stop container
sudo docker start sql_VR_1   

#Sleep 30 sec - it takes time for sql to start
Sleep 30

#Stop container
sudo docker stop sql_VR_1 

#Remove container. THis actually doesn't remove image file
sudo docker rm sql_VR_1

#THis removes docker image file from local repo
docker images #-- Get IMAGE_ID
sudo docker rmi 91ac25f0495b

#------- Save cintainer into image with your changes

#list images. Check Container ID which you are working on
docker images
docker ps -a

#-- Create new image localy (or you can push it to GitHub at creation)
docker commit 31b78336ee2c vrojkov/mssql-server-linux_testdb_01:2017-Test_DB_01


#-- check result
docker images
docker ps -a

#-- Start SQL using new image. Some params not required, like sa pwd and ACCEPT_EULA, you can even skip port# and name
sudo docker run -p 4433:1433 --name sql_VR_Test_DB_01 \
   -d vrojkov/mssql-server-linux_testdb_01:2017-Test_DB_01

sudo docker start sql_VR_Test_DB_01
Sleep 15

#-- lookl inside the Docker. To find where db fileslocated Run via SQL OpSt: select * from sys.database_files   
docker exec -it sql_VR_Test_DB_01 /bin/bash
ls /var/opt/mssql/data/ -l


#-- Push new image to DockerHub repo. Using username and pwd. Altrantivelly can use your e-mail in the command string instead of pwd 
docker login --username=vrojkov

docker push  vrojkov/mssql-server-linux_testdb_01:2017-Test_DB_01

#-- Pull image from GitHub
docker pull vrojkov/mssql-server-linux_testdb_01:2017-Test_DB_01

#-- Copy files to and from docker
#-- From docker to Win container with Virtual box into folder /C/Users/n1203739a/TMP/
 docker cp sql_VR_Test_DB_01:/install/Docker_TEST_DB01.bak ./TMP
#-- To Docker from to Win container with Virtual box
docker cp ./TMP/Docker_TEST_DB01_V2.bak sql_VR_Test_DB_01:/install/


