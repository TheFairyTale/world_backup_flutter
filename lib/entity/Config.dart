class Config {
  // 选择要备份到哪个目录中
  String backupFolderPath;
  // 存档所在文件夹（选择world 文件夹所在的文件夹）
  String worldFolderPath;
  // 备份时间间隔
  String backupInterview;

  Config(
      {this.backupFolderPath = "",
      this.worldFolderPath = "",
      this.backupInterview = ""});

  factory Config.fromJson(Map<String, dynamic> json) {
    json['backupInterview'];
    json['worldFolderPath'];
    json['backupFolderPath'];
    if () {

    }

    return Config(
        backupFolderPath: ,
        worldFolderPath: ,
        backupInterview: );
  }
}
