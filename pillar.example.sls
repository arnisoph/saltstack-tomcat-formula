java:
  jdk:
    current_ver: 8u20
    versions:
      8u20:
        source: http://fipmb1012.domain.de/share/java/jdk-8u20-linux-x64.tar.gz
        source_hash: md5=ec7f89dc3697b402e2c851d0488f6299
        version: jdk1.8.0_20

tomcat:
  lookup:
    instances:
      i0:
        version: 8.0.18
        source: http://fipmb1012.domain.de/share/tomcat/apache-tomcat-8.0.18.tar.gz
        source_hash: md5=00a4f4790e777a2c5b1ed966de3e2f56
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
              source: http://fipmb1012.domain.de/share/jenkins/war/1.598/jenkins.war
              source_hash: sha512=b059869971dc14db0398fa1727df8ed1446fa21b0ed25697c1eef8fe9044ca720b61cfa3b4a38ba8e3101bb0c34f82ec8cb18516f80c9c2359a7e04fe040cfe2
tomcat-manager:
  user: tomcat-salt
  passwd: tomcat-salt-user-password42
