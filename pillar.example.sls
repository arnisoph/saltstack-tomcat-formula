java:
  lookup:
    manage:
      jdk:
        current_ver: 8u20
        versions:
          8u20:
            source: file:///vagrant/share/misc/jdk-8u20-linux-x64.tar.gz
            source_hash: md5=ec7f89dc3697b402e2c851d0488f6299
            version: jdk1.8.0_20
users:
  manage:
    tomcat:
      home: /var/lib/tomcat
      shell: /bin/false
      system: True
      groups:
        - tomcat

groups:
  manage:
    tomcat:
      system: True

sysctl:
  params:
    - name: vm.swappiness
      value: 0

tomcat:
  lookup:
    instances:
      i1:
        id: 1
        cur_version: 8.0.20
        source: 'file:///vagrant/share/misc/apache-tomcat-8.0.20.tar.gz'
        source_hash: md5=9a3dacfbe9644d7a23699b4aa9f648df
        versions:
          '8_0_20':
            version: 8.0.20
            settings:
              users:
                plain: |
                  <role rolename="manager"/>
                  <user username="admin" password="admin" roles="manager-gui"/>
                  <user username="deploy" password="admin" roles="manager-script,manager-gui"/>
                  <user username="tomcat-salt" password="tomcat-salt-user-password42" roles="manager-script,manager-gui"/>
            files:
              manage:
                - setenv
                - server
                - tomcat_users
                - init
              setenv:
                contents: |
                  export \
                  JAVA_OPTS="-Xms128m -Xmx128m" \
                  JAVA_HOME=/opt/java/jdk/current/src/ \
                  JAVA_OPTS="\
                    -Djava.net.preferIPv4Stack=true \
                    -Dhudson.DNSMultiCast.disabled=true \
                    "
              init:
                path: /etc/init.d/tomcat-i1
            webapps:
              docs:
                manage: True
                ensure: absent
              examples:
                manage: True
                ensure: absent
              host_manager:
                alias: host-manager
                manage: True
                ensure: absent
              manager:
                manage: False
              ROOT:
                manage: True
                ensure: absent
              jenkins:
                manage: True
                war:
                  deployment_type: manager
                  url: 'http://10.10.11.100:18080/manager'
                  source: 'file:///vagrant/share/misc/jenkins.war'
                  #source: 'http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
                  #source_hash: sha512=b059869971dc14db0398fa1727df8ed1446fa21b0ed25697c1eef8fe9044ca720b61cfa3b4a38ba8e3101bb0c34f82ec8cb18516f80c9c2359a7e04fe040cfe2
tomcat-manager:
  user: tomcat-salt
  passwd: tomcat-salt-user-password42
