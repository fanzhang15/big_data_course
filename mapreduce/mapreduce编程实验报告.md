## 一、实验名称

Mapreduce编程实验

## 二、实验目的

掌握mapreduce 的基本使用

## 三、实验环境

Hadoop

IDEA+插件Bigdata tool

## 四、实验内容及步骤

### 1. 准备

####     (1)  新建maven工程，在pom.xml文件中添加依赖

```xml
<dependencies>
        <dependency>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.0</version>
        </dependency>

        <dependency>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <version>3.5.0</version>
        </dependency>
        
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>3.3.4</version>
            <exclusions>
                <exclusion>
                    <artifactId>jackson-annotations</artifactId>
                    <groupId>com.fasterxml.jackson.core</groupId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.30</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.26</version>
            <scope>provided</scope>
        </dependency>


        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>3.3.4</version>
        </dependency>

        <dependency>
            <groupId>com.google.protobuf</groupId>
            <artifactId>protobuf-java</artifactId>
            <version>3.21.12</version>
        </dependency>

    </dependencies>

<build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <plugin>
                <artifactId>maven-assembly-plugin</artifactId>
                <configuration>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

#### 	(2) 新建工程包

![](pic\1新建包.png)

#### (3) 上传测试数据到hdfs

![](pic\2上传hdfs测试数据.png)









### 2. 编写wordcount代码

#### 		(1) mapper

```java
/**
 * KEYIN, map阶段输入的key的类型：LongWritable
 * VALUEIN,map阶段输入value类型：Text
 * KEYOUT,map阶段输出的Key类型：Text
 * VALUEOUT,map阶段输出的value类型：IntWritable
 */
public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private Text outK = new Text();
    private IntWritable outV = new IntWritable(1);
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // 1 获取一行
        String line = value.toString();
        // 2 切割
        String[] words = line.split(" ");
        // 3 循环写出
        for (String word : words) {
            // 封装outk
            outK.set(word);
            // 写出
            context.write(outK, outV);
        }
    }
}
```

#### 		(2) reducer

```java

/**
 * KEYIN, reduce阶段输入的key的类型：Text
 * VALUEIN,reduce阶段输入value类型：IntWritable
 * KEYOUT,reduce阶段输出的Key类型：Text
 * VALUEOUT,reduce阶段输出的value类型：IntWritable
 */
public class WordCountReducer extends Reducer<Text, IntWritable,Text,IntWritable> {
    private IntWritable outV = new IntWritable();

    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {

        int sum = 0;
        // 累加
        for (IntWritable value : values) {
            sum += value.get();
        }

        outV.set(sum);

        // 写出
        context.write(key,outV);
    }
}
```

#### 		(3)  driver

```java
public class WordCountDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar包路径
        job.setJarByClass(WordCountDriver.class);

        // 3 关联mapper和reducer
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);

        // 4 设置map输出的kv类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        // 5 设置最终输出的kV类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // 6 设置输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);

        System.exit(result ? 0 : 1);
    }
}
```

#### 	(4) 远程调试

![](pic\3修改运行配置.png)

![](pic\4配置ssh.png)

![5填写java运行的参数](pic\5填写java运行的参数.png)

![](pic\6上传资源到服务器.png)

![7开始运行程序](pic\7开始运行程序.png)

![8运行完成](pic\8运行完成.png)

![9输出的文件](pic\9输出的文件.png)

#### 	(5) 命令行提交测试

##### 		1) 打包

![](pic\10打包.png)

![11打包完成](pic\11打包完成.png)

##### 	2) 上传mr-demo-1.0-SNAPSHOT-jar-with-dependencies.jar到hadoop101，执行命令  

**重新运行的时候要删除输出的文件夹，或者换一个输出路径**

```shell
hadoop jar mr-demo-1.0-SNAPSHOT-jar-with-dependencies.jar com.xxx.demo.driver.WordCountDriver \
hdfs://192.168.79.101:9000/test_data/input/1wordcount/ \
hdfs://192.168.79.101:9000/test_data/output/1wordcount/
```

![](pic\12jar提交结果.png)

### 3. 序列化实操

统计每一个手机号耗费的总上行流量、总下行流量、总流量

#### (1) bean

```java

/**
 * 1、定义类实现writable接口
 * 2、重写序列化和反序列化方法
 * 3、重写空参构造
 * 4、toString方法
 */
public class FlowBean implements Writable {
    private long upFlow; // 上行流量
    private long downFlow; // 下行流量
    private long sumFlow; // 总流量

    // 空参构造
    public FlowBean() {
    }

    public long getUpFlow() {
        return upFlow;
    }

    public void setUpFlow(long upFlow) {
        this.upFlow = upFlow;
    }

    public long getDownFlow() {
        return downFlow;
    }

    public void setDownFlow(long downFlow) {
        this.downFlow = downFlow;
    }

    public long getSumFlow() {
        return sumFlow;
    }

    public void setSumFlow(long sumFlow) {
        this.sumFlow = sumFlow;
    }
    public void setSumFlow() {
        this.sumFlow = this.upFlow + this.downFlow;
    }

    @Override
    public void write(DataOutput out) throws IOException {

        out.writeLong(upFlow);
        out.writeLong(downFlow);
        out.writeLong(sumFlow);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.upFlow = in.readLong();
        this.downFlow = in.readLong();
        this.sumFlow = in.readLong();
    }

    @Override
    public String toString() {
        return upFlow + "\t" + downFlow + "\t" + sumFlow;
    }
}
```

#### (2) mapper

```java

public class FlowMapper extends Mapper<LongWritable, Text, Text, FlowBean> {

    private Text outK = new Text();
    private FlowBean outV = new FlowBean();

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 1 获取一行
        // 1	13736230513	192.196.100.1	www.that.com	2481	24681	200
        String line = value.toString();

        // 2 切割
        // 1,13736230513,192.196.100.1,www.that.com,2481,24681,200   7 - 3= 4
        // 2	13846544121	192.196.100.2			264	0	200  6 - 3 = 3
        String[] split = line.split("\t");

        // 3 抓取想要的数据
        // 手机号：13736230513
        // 上行流量和下行流量：2481,24681
        String phone = split[1];
        String up = split[split.length - 3];
        String down  = split[split.length - 2];

        // 4封装
        outK.set(phone);
        outV.setUpFlow(Long.parseLong(up));
        outV.setDownFlow(Long.parseLong(down));
        outV.setSumFlow();

        // 5 写出
        context.write(outK, outV);
    }
}
```

#### (3) reducer

```java

public class FlowReducer extends Reducer<Text, FlowBean,Text, FlowBean> {
    private FlowBean outV = new FlowBean();

    @Override
    protected void reduce(Text key, Iterable<FlowBean> values, Context context) throws IOException, InterruptedException {

        // 1 遍历集合累加值
        long totalUp = 0;
        long totaldown = 0;

        for (FlowBean value : values) {
            totalUp += value.getUpFlow();
            totaldown += value.getDownFlow();
        }

        // 2 封装outk, outv
        outV.setUpFlow(totalUp);
        outV.setDownFlow(totaldown);
        outV.setSumFlow();

        // 3 写出
        context.write(key, outV);
    }
}
```

#### (4) driver

```java

public class FlowDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar
        job.setJarByClass(FlowDriver.class);

        // 3 关联mapper 和Reducer
        job.setMapperClass(FlowMapper.class);
        job.setReducerClass(FlowReducer.class);

        // 4 设置mapper 输出的key和value类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(FlowBean.class);

        // 5 设置最终数据输出的key和value类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(FlowBean.class);

        // 6 设置数据的输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);
        System.exit(result ? 0 : 1);
    }
}
```

#### (5) 输出结果

![](pic\13序列化输出结果.png)

### 4. CombineTextInputFormat案例实操

将输入的大量小文件合并成一个切片统一处理。

#### (1) bean

#### (2) mapper

```java

/**
 * KEYIN, map阶段输入的key的类型：LongWritable
 * VALUEIN,map阶段输入value类型：Text
 * KEYOUT,map阶段输出的Key类型：Text
 * VALUEOUT,map阶段输出的value类型：IntWritable
 */
public class CombineTextInputforamtWcMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private Text outK = new Text();
    private IntWritable outV = new IntWritable(1);

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 1 获取一行
        String line = value.toString();

        // 2 切割
        String[] words = line.split(" ");

        // 3 循环写出
        for (String word : words) {
            // 封装outk
            outK.set(word);

            // 写出
            context.write(outK, outV);
        }
    }
}
```



#### (3) reducer

```java

/**
 * KEYIN, reduce阶段输入的key的类型：Text
 * VALUEIN,reduce阶段输入value类型：IntWritable
 * KEYOUT,reduce阶段输出的Key类型：Text
 * VALUEOUT,reduce阶段输出的value类型：IntWritable
 */
public class CombineTextInputforamtWcReducer extends Reducer<Text, IntWritable,Text,IntWritable> {
    private IntWritable outV = new IntWritable();

    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {

        int sum = 0;
        // 累加
        for (IntWritable value : values) {
            sum += value.get();
        }

        outV.set(sum);

        // 写出
        context.write(key,outV);
    }
}

```



#### (4) driver

```java

public class CombineTextInputforamtWcDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar包路径
        job.setJarByClass(CombineTextInputforamtWcDriver.class);

        // 3 关联mapper和reducer
        job.setMapperClass(CombineTextInputforamtWcMapper.class);
        job.setReducerClass(CombineTextInputforamtWcReducer.class);

        // 4 设置map输出的kv类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        // 5 设置最终输出的kV类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // 如果不设置InputFormat，它默认用的是TextInputFormat.class
        job.setInputFormatClass(CombineTextInputFormat.class);

        //虚拟存储切片最大值设置4m(4194304),20M(20971520)
        CombineTextInputFormat.setMaxInputSplitSize(job, 4194304);
        //CombineTextInputFormat.setMaxInputSplitSize(job, 20971520);


        // 6 设置输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);

        System.exit(result ? 0 : 1);
    }
}
```



#### (5) 输出结果

运行两次，修改CombineTextInputFormat.setMaxInputSplitSize的大小，查看输出的结果

![](pic\14split4.png)

![15split20](pic\15split20.png)

### 5. Partition分区案例实操

将统计结果按照手机归属地不同省份输出到不同文件中（分区）

#### (1) bean

```java

/**
 * 1、定义类实现writable接口
 * 2、重写序列化和反序列化方法
 * 3、重写空参构造
 * 4、toString方法
 */
public class FlowBean implements Writable {
    private long upFlow; // 上行流量
    private long downFlow; // 下行流量
    private long sumFlow; // 总流量

    // 空参构造
    public FlowBean() {
    }

    public long getUpFlow() {
        return upFlow;
    }

    public void setUpFlow(long upFlow) {
        this.upFlow = upFlow;
    }

    public long getDownFlow() {
        return downFlow;
    }

    public void setDownFlow(long downFlow) {
        this.downFlow = downFlow;
    }

    public long getSumFlow() {
        return sumFlow;
    }

    public void setSumFlow(long sumFlow) {
        this.sumFlow = sumFlow;
    }
    public void setSumFlow() {
        this.sumFlow = this.upFlow + this.downFlow;
    }

    @Override
    public void write(DataOutput out) throws IOException {

        out.writeLong(upFlow);
        out.writeLong(downFlow);
        out.writeLong(sumFlow);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.upFlow = in.readLong();
        this.downFlow = in.readLong();
        this.sumFlow = in.readLong();
    }

    @Override
    public String toString() {
        return upFlow + "\t" + downFlow + "\t" + sumFlow;
    }
}
```



#### (2) mapper

```java

public class FlowMapper extends Mapper<LongWritable, Text, Text, FlowBean> {

    private Text outK = new Text();
    private FlowBean outV = new FlowBean();

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 1 获取一行
        // 1	13736230513	192.196.100.1	www.that.com	2481	24681	200
        String line = value.toString();

        // 2 切割
        // 1,13736230513,192.196.100.1,www.that.com,2481,24681,200   7 - 3= 4
        // 2	13846544121	192.196.100.2			264	0	200  6 - 3 = 3
        String[] split = line.split("\t");

        // 3 抓取想要的数据
        // 手机号：13736230513
        // 上行流量和下行流量：2481,24681
        String phone = split[1];
        String up = split[split.length - 3];
        String down  = split[split.length - 2];

        // 4封装
        outK.set(phone);
        outV.setUpFlow(Long.parseLong(up));
        outV.setDownFlow(Long.parseLong(down));
        outV.setSumFlow();

        // 5 写出
        context.write(outK, outV);
    }
}
```



#### (3) reducer

```java

public class FlowReducer extends Reducer<Text, FlowBean,Text, FlowBean> {
    private FlowBean outV = new FlowBean();

    @Override
    protected void reduce(Text key, Iterable<FlowBean> values, Context context) throws IOException, InterruptedException {

        // 1 遍历集合累加值
        long totalUp = 0;
        long totaldown = 0;

        for (FlowBean value : values) {
            totalUp += value.getUpFlow();
            totaldown += value.getDownFlow();
        }

        // 2 封装outk, outv
        outV.setUpFlow(totalUp);
        outV.setDownFlow(totaldown);
        outV.setSumFlow();

        // 3 写出
        context.write(key, outV);
    }
}
```



#### (4) partition

```java

public class ProvincePartitioner extends Partitioner<Text, FlowBean> {
    @Override
    public int getPartition(Text text, FlowBean flowBean, int numPartitions) {
        // text 是手机号

        String phone = text.toString();

        String prePhone = phone.substring(0, 3);

        int partition ;

        if ("136".equals(prePhone)){
            partition = 0;
        }else if ("137".equals(prePhone)){
            partition = 1;
        }else if ("138".equals(prePhone)){
            partition = 2;
        }else if ("139".equals(prePhone)){
            partition = 3;
        }else {
            partition = 4;
        }

        return partition;
    }
}
```



#### (5) driver

```java

public class FlowPartitionDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar
        job.setJarByClass(FlowDriver.class);

        // 3 关联mapper 和Reducer
        job.setMapperClass(FlowMapper.class);
        job.setReducerClass(FlowReducer.class);

        // 4 设置mapper 输出的key和value类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(FlowBean.class);

        // 5 设置最终数据输出的key和value类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(FlowBean.class);

        job.setPartitionerClass(ProvincePartitioner.class);
        job.setNumReduceTasks(6);


        // 6 设置数据的输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);
        System.exit(result ? 0 : 1);
    }
}
```

#### (6) 输出结果

![](pic\16result_partition.png)

### 6.WritableComparable排序案例实操（全局排序）

根据案例3序列化案例产生的结果再次对总流量进行倒序排序

#### (1) bean

```java

/**
 * 1、定义类实现writable接口
 * 2、重写序列化和反序列化方法
 * 3、重写空参构造
 * 4、toString方法
 */
public class FlowGlobalSortBean implements WritableComparable<FlowGlobalSortBean> {
    private long upFlow; // 上行流量
    private long downFlow; // 下行流量
    private long sumFlow; // 总流量

    // 空参构造
    public FlowGlobalSortBean() {
    }

    public long getUpFlow() {
        return upFlow;
    }

    public void setUpFlow(long upFlow) {
        this.upFlow = upFlow;
    }

    public long getDownFlow() {
        return downFlow;
    }

    public void setDownFlow(long downFlow) {
        this.downFlow = downFlow;
    }

    public long getSumFlow() {
        return sumFlow;
    }

    public void setSumFlow(long sumFlow) {
        this.sumFlow = sumFlow;
    }

    public void setSumFlow() {
        this.sumFlow = this.upFlow + this.downFlow;
    }

    @Override
    public void write(DataOutput out) throws IOException {

        out.writeLong(upFlow);
        out.writeLong(downFlow);
        out.writeLong(sumFlow);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.upFlow = in.readLong();
        this.downFlow = in.readLong();
        this.sumFlow = in.readLong();
    }

    @Override
    public String toString() {
        return upFlow + "\t" + downFlow + "\t" + sumFlow;
    }

    @Override
    public int compareTo(FlowGlobalSortBean o) {

        // 总流量的倒序排序
        if (this.sumFlow > o.sumFlow) {
            return -1;
        } else if (this.sumFlow < o.sumFlow) {
            return 1;
        } else {
            // 按照上行流量的正序排
            if (this.upFlow > o.upFlow) {
                return 1;
            } else if (this.upFlow < o.upFlow) {
                return -1;
            } else {

                return 0;
            }
        }
    }
}
```



#### (2) mapper

```java

public class FlowGlobalSortMapper extends Mapper<LongWritable, Text, FlowGlobalSortBean, Text> {

    private FlowGlobalSortBean outK = new FlowGlobalSortBean();
    private Text outV = new Text();

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 获取一行
        String line = value.toString();

        // 切割
        String[] split = line.split("\t");

        // 封装
        outV.set(split[1]);
        outK.setUpFlow(Long.parseLong(split[split.length - 3]));
        outK.setDownFlow(Long.parseLong(split[split.length - 2]));
        outK.setSumFlow();

        // 写出
        context.write(outK, outV);
    }
}
```



#### (3) reducer

```java
public class FlowGlobalSortReducer extends Reducer<FlowGlobalSortBean, Text, Text, FlowGlobalSortBean> {

    @Override
    protected void reduce(FlowGlobalSortBean key, Iterable<Text> values, Context context) throws IOException, InterruptedException {

        for (Text value : values) {

            context.write(value,key);
        }
    }
}

```



#### (4) driver

```java
public class FlowGlobalSortDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar
        job.setJarByClass(FlowDriver.class);

        // 3 关联mapper 和Reducer
        job.setMapperClass(FlowGlobalSortMapper.class);
        job.setReducerClass(FlowGlobalSortReducer.class);

        // 4 设置mapper 输出的key和value类型
        job.setMapOutputKeyClass(FlowGlobalSortBean.class);
        job.setMapOutputValueClass(Text.class);

        // 5 设置最终数据输出的key和value类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(FlowGlobalSortBean.class);

        // 6 设置数据的输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);
        System.exit(result ? 0 : 1);
    }
}
```



#### (5) 输出结果

![](pic\17result_globalsort.png)

### 7.WritableComparable排序案例实操（区内排序）

要求每个省份手机号输出的文件中按照总流量内部排序。

#### (1) bean

```java

/**
 * 1、定义类实现writable接口
 * 2、重写序列化和反序列化方法
 * 3、重写空参构造
 * 4、toString方法
 */
public class FlowGlobalSortBean implements WritableComparable<FlowGlobalSortBean> {
    private long upFlow; // 上行流量
    private long downFlow; // 下行流量
    private long sumFlow; // 总流量

    // 空参构造
    public FlowGlobalSortBean() {
    }

    public long getUpFlow() {
        return upFlow;
    }

    public void setUpFlow(long upFlow) {
        this.upFlow = upFlow;
    }

    public long getDownFlow() {
        return downFlow;
    }

    public void setDownFlow(long downFlow) {
        this.downFlow = downFlow;
    }

    public long getSumFlow() {
        return sumFlow;
    }

    public void setSumFlow(long sumFlow) {
        this.sumFlow = sumFlow;
    }

    public void setSumFlow() {
        this.sumFlow = this.upFlow + this.downFlow;
    }

    @Override
    public void write(DataOutput out) throws IOException {

        out.writeLong(upFlow);
        out.writeLong(downFlow);
        out.writeLong(sumFlow);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.upFlow = in.readLong();
        this.downFlow = in.readLong();
        this.sumFlow = in.readLong();
    }

    @Override
    public String toString() {
        return upFlow + "\t" + downFlow + "\t" + sumFlow;
    }

    @Override
    public int compareTo(FlowGlobalSortBean o) {

        // 总流量的倒序排序
        if (this.sumFlow > o.sumFlow) {
            return -1;
        } else if (this.sumFlow < o.sumFlow) {
            return 1;
        } else {
            // 按照上行流量的正序排
            if (this.upFlow > o.upFlow) {
                return 1;
            } else if (this.upFlow < o.upFlow) {
                return -1;
            } else {

                return 0;
            }
        }
    }
}
```



#### (2) mapper

```java

public class FlowGlobalSortMapper extends Mapper<LongWritable, Text, FlowGlobalSortBean, Text> {

    private FlowGlobalSortBean outK = new FlowGlobalSortBean();
    private Text outV = new Text();

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 获取一行
        String line = value.toString();

        // 切割
        String[] split = line.split("\t");

        // 封装
        outV.set(split[1]);
        outK.setUpFlow(Long.parseLong(split[split.length - 3]));
        outK.setDownFlow(Long.parseLong(split[split.length - 2]));
        outK.setSumFlow();

        // 写出
        context.write(outK, outV);
    }
}
```



#### (3) reducer

```java
public class FlowGlobalSortReducer extends Reducer<FlowGlobalSortBean, Text, Text, FlowGlobalSortBean> {

    @Override
    protected void reduce(FlowGlobalSortBean key, Iterable<Text> values, Context context) throws IOException, InterruptedException {

        for (Text value : values) {

            context.write(value,key);
        }
    }
}

```



#### (4) partition

```java

public class ProvincePartitionSort extends Partitioner<FlowGlobalSortBean, Text> {
    @Override
    public int getPartition(FlowGlobalSortBean FlowGlobalSortBean, Text text, int numPartitions) {

        String phone = text.toString();

        String prePhone = phone.substring(0, 3);

        int partition;
        if ("136".equals(prePhone)){
            partition =  0;
        }else if ("137".equals(prePhone)){
            partition =  1;
        }else if ("138".equals(prePhone)){
            partition =  2;
        }else if ("139".equals(prePhone)){
            partition =  3;
        }else {
            partition = 4;
        }

        return partition;
    }
}
```



#### (5) driver

```java

public class FlowPartitionSortDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar
        job.setJarByClass(FlowDriver.class);

        // 3 关联mapper 和Reducer
        job.setMapperClass(FlowGlobalSortMapper.class);
        job.setReducerClass(FlowGlobalSortReducer.class);

        // 4 设置mapper 输出的key和value类型
        job.setMapOutputKeyClass(FlowGlobalSortBean.class);
        job.setMapOutputValueClass(Text.class);

        // 5 设置最终数据输出的key和value类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(FlowGlobalSortBean.class);

        job.setPartitionerClass(ProvincePartitionSort.class);
        job.setNumReduceTasks(5);


        // 6 设置数据的输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);
        System.exit(result ? 0 : 1);
    }
}
```

#### (6) 输出结果

![](pic\18result_partition_sort.png)

### 8.Combiner合并案例实操

统计过程中对每一个MapTask的输出进行局部汇总，以减小网络传输量即采用Combiner功能

#### (1) bean

#### (2) mapper

```java
/**
 * KEYIN, map阶段输入的key的类型：LongWritable
 * VALUEIN,map阶段输入value类型：Text
 * KEYOUT,map阶段输出的Key类型：Text
 * VALUEOUT,map阶段输出的value类型：IntWritable
 */
public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private Text outK = new Text();
    private IntWritable outV = new IntWritable(1);

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 1 获取一行
        String line = value.toString();

        // 2 切割
        String[] words = line.split(" ");

        // 3 循环写出
        for (String word : words) {
            // 封装outk
            outK.set(word);

            // 写出
            context.write(outK, outV);
        }
    }
}
```



#### (3) reducer

```java

/**
 * KEYIN, reduce阶段输入的key的类型：Text
 * VALUEIN,reduce阶段输入value类型：IntWritable
 * KEYOUT,reduce阶段输出的Key类型：Text
 * VALUEOUT,reduce阶段输出的value类型：IntWritable
 */
public class WordCountReducer extends Reducer<Text, IntWritable,Text,IntWritable> {
    private IntWritable outV = new IntWritable();

    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {

        int sum = 0;
        // 累加
        for (IntWritable value : values) {
            sum += value.get();
        }

        outV.set(sum);

        // 写出
        context.write(key,outV);
    }
}
```



#### (4) combimer

```java

public class WordCountCombiner extends Reducer<Text, IntWritable,Text, IntWritable> {

    private IntWritable outV = new IntWritable();
    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {

        int sum =0;
        for (IntWritable value : values) {
            sum += value.get();
        }

        outV.set(sum);

        context.write(key,outV);
    }
}
```



#### (5) driver

```java

public class WordCountCombinerDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 设置jar包路径
        job.setJarByClass(WordCountCombinerDriver.class);

        // 3 关联mapper和reducer
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);

        // 4 设置map输出的kv类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        // 5 设置最终输出的kV类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        job.setCombinerClass(WordCountCombiner.class);

        // 6 设置输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 7 提交job
        boolean result = job.waitForCompletion(true);

        System.exit(result ? 0 : 1);
    }
}
```



#### (6) 输出结果

![](pic\19combine.png)

### 9.自定义OutputFormat案例实操

过滤输入的log日志，包含xxxx的url

#### (1) bean

#### (2) mapper

```java

public class LogMapper extends Mapper<LongWritable, Text,Text, NullWritable> {

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // http://www.baidu.com
        //http://www.google.com
        // (http://www.google.com, NullWritable)
        // 不做任何处理
        context.write(value, NullWritable.get());
    }
}
```



#### (3) reducer

```java

public class LogReducer extends Reducer<Text, NullWritable, Text, NullWritable> {

    @Override
    protected void reduce(Text key, Iterable<NullWritable> values, Context context) throws IOException, InterruptedException {

        // http://www.baidu.com
        // http://www.baidu.com
        // 防止有相同数据，丢数据
        for (NullWritable value : values) {
            context.write(key, NullWritable.get());
        }
    }
}
```

#### (4) outputformat

```java
public class LogOutputFormat extends FileOutputFormat<Text, NullWritable> {
    @Override
    public RecordWriter<Text, NullWritable> getRecordWriter(TaskAttemptContext job) throws IOException, InterruptedException {

        LogRecordWriter lrw = new LogRecordWriter(job);

        return lrw;
    }
}
```

```java

public class LogRecordWriter extends RecordWriter<Text, NullWritable> {

    private  FSDataOutputStream mainOut;
    private  FSDataOutputStream otherOut;

    public LogRecordWriter(TaskAttemptContext job) {
        // 创建两条流
        try {
            FileSystem fs = FileSystem.get(job.getConfiguration());

            mainOut = fs.create(new Path("hdfs://192.168.79.101:9000/test_data/output/8outputformat/main.log"));

            otherOut = fs.create(new Path("hdfs://192.168.79.101:9000/test_data/output/8outputformat/other.log"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void write(Text key, NullWritable value) throws IOException, InterruptedException {
        String log = key.toString();

        // 具体写
        if (log.contains("xxxx")){
            mainOut.writeBytes(log+"\n");
        }else {
            otherOut.writeBytes(log+"\n");
        }
    }

    @Override
    public void close(TaskAttemptContext context) throws IOException, InterruptedException {
        // 关流
        IOUtils.closeStream(mainOut);
        IOUtils.closeStream(otherOut);
    }
}
```



#### (5) driver

```java

public class LogDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        job.setJarByClass(LogDriver.class);
        job.setMapperClass(LogMapper.class);
        job.setReducerClass(LogReducer.class);

        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(NullWritable.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NullWritable.class);

        //设置自定义的outputformat
        job.setOutputFormatClass(LogOutputFormat.class);

        FileInputFormat.setInputPaths(job, new Path(args[0]));
        //虽然我们自定义了outputformat，但是因为我们的outputformat继承自fileoutputformat
        //而fileoutputformat要输出一个_SUCCESS文件，所以在这还得指定一个输出目录
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        boolean b = job.waitForCompletion(true);
        System.exit(b ? 0 : 1);

    }
}
```



#### (6) 输出结果

![](pic\20result_outputformat.png)

### 10. Reduce Join案例实操

将商品信息表中数据根据商品pid合并到订单数据表中

分析：通过将关联条件作为Map输出的key，将两表满足Join条件的数据并携带数据所来源的文件信息，发往同一个ReduceTask，在Reduce中进行数据的串联。

#### (1) bean

```java

public class TableBean implements Writable {

    private String id; // 订单id
    private String pid; // 商品id
    private int amount; // 商品数量
    private String pname;// 商品名称
    private String flag; // 标记是什么表 order pd

    // 空参构造
    public TableBean() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPid() {
        return pid;
    }

    public void setPid(String pid) {
        this.pid = pid;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getPname() {
        return pname;
    }

    public void setPname(String pname) {
        this.pname = pname;
    }

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeUTF(id);
        out.writeUTF(pid);
        out.writeInt(amount);
        out.writeUTF(pname);
        out.writeUTF(flag);
    }

    @Override
    public void readFields(DataInput in) throws IOException {

        this.id = in.readUTF();
        this.pid = in.readUTF();
        this.amount = in.readInt();
        this.pname = in.readUTF();
        this.flag = in.readUTF();
    }

    @Override
    public String toString() {
        // id	pname	amount
        return  id + "\t" +  pname + "\t" + amount ;
    }
}
```



#### (2) mapper

```java

public class TableMapper extends Mapper<LongWritable, Text, Text, TableBean> {

    private String fileName;
    private Text outK  = new Text();
    private TableBean outV = new TableBean();

    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        // 初始化  order  pd
        FileSplit split = (FileSplit) context.getInputSplit();

        fileName = split.getPath().getName();
    }

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // 1 获取一行
        String line = value.toString();

        // 2 判断是哪个文件的
        if (fileName.contains("order")){// 处理的是订单表

            String[] split = line.split("\t");

            // 封装k  v
            outK.set(split[1]);
            outV.setId(split[0]);
            outV.setPid(split[1]);
            outV.setAmount(Integer.parseInt(split[2]));
            outV.setPname("");
            outV.setFlag("order");

        }else {// 处理的是商品表
            String[] split = line.split("\t");

            outK.set(split[0]);
            outV.setId("");
            outV.setPid(split[0]);
            outV.setAmount(0);
            outV.setPname(split[1]);
            outV.setFlag("pd");
        }

        // 写出
        context.write(outK, outV);
    }
}
```



#### (3) reducer

```java

public class TableReducer extends Reducer<Text, TableBean,TableBean, NullWritable> {

    @Override
    protected void reduce(Text key, Iterable<TableBean> values, Context context) throws IOException, InterruptedException {
//        01 	1001	1   order
//        01 	1004	4   order
//        01	小米   	     pd
        // 准备初始化集合
        ArrayList<TableBean> orderBeans = new ArrayList<>();
        TableBean pdBean = new TableBean();

        // 循环遍历
        for (TableBean value : values) {

            if ("order".equals(value.getFlag())){// 订单表

                TableBean tmptableBean = new TableBean();

                try {
                    BeanUtils.copyProperties(tmptableBean,value);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }

                orderBeans.add(tmptableBean);
            }else {// 商品表

                try {
                    BeanUtils.copyProperties(pdBean,value);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }

        // 循环遍历orderBeans，赋值 pdname
        for (TableBean orderBean : orderBeans) {

            orderBean.setPname(pdBean.getPname());

            context.write(orderBean,NullWritable.get());
        }
    }
}
```



#### (4) driver

```java

public class TableDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        Job job = Job.getInstance(new Configuration());

        job.setJarByClass(TableDriver.class);
        job.setMapperClass(TableMapper.class);
        job.setReducerClass(TableReducer.class);

        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(TableBean.class);

        job.setOutputKeyClass(TableBean.class);
        job.setOutputValueClass(NullWritable.class);

        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        boolean b = job.waitForCompletion(true);
        System.exit(b ? 0 : 1);
    }

}
```



#### (5) 输出结果

![](pic\21result_reducejoin.png)

### 11. Map Join案例实操

#### (1) bean

```java

public class TableBean implements Writable {

    private String id; // 订单id
    private String pid; // 商品id
    private int amount; // 商品数量
    private String pname;// 商品名称
    private String flag; // 标记是什么表 order pd

    // 空参构造
    public TableBean() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPid() {
        return pid;
    }

    public void setPid(String pid) {
        this.pid = pid;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getPname() {
        return pname;
    }

    public void setPname(String pname) {
        this.pname = pname;
    }

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeUTF(id);
        out.writeUTF(pid);
        out.writeInt(amount);
        out.writeUTF(pname);
        out.writeUTF(flag);
    }

    @Override
    public void readFields(DataInput in) throws IOException {

        this.id = in.readUTF();
        this.pid = in.readUTF();
        this.amount = in.readInt();
        this.pname = in.readUTF();
        this.flag = in.readUTF();
    }

    @Override
    public String toString() {
        // id	pname	amount
        return  id + "\t" +  pname + "\t" + amount ;
    }
}
```



#### (2) mapper

```java

public class MapJoinMapper extends Mapper<LongWritable, Text, Text, NullWritable> {
    private HashMap<String, String> pdMap = new HashMap<>();
    private Text outK = new Text();

    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        // 获取缓存的文件，并把文件内容封装到集合 pd.txt
        URI[] cacheFiles = context.getCacheFiles();

        FileSystem fs = FileSystem.get(context.getConfiguration());
        FSDataInputStream fis = fs.open(new Path(cacheFiles[0]));

        // 从流中读取数据
        BufferedReader reader = new BufferedReader(new InputStreamReader(fis, "UTF-8"));

        String line;
        while (StringUtils.isNotEmpty(line = reader.readLine())) {
            // 切割
            String[] fields = line.split("\t");

            // 赋值
            pdMap.put(fields[0], fields[1]);
        }

        // 关流
        IOUtils.closeStream(reader);
    }

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 处理 order.txt
        String line = value.toString();

        String[] fields = line.split("\t");

        // 获取pid
        String pname = pdMap.get(fields[1]);

        // 获取订单id 和订单数量
        // 封装
        outK.set(fields[0] + "\t" + pname + "\t" + fields[2]);

        context.write(outK, NullWritable.get());
    }
}
```



#### (3) reducer

#### (4) driver

```java

public class MapJoinDriver {
    public static void main(String[] args) throws IOException, URISyntaxException, ClassNotFoundException, InterruptedException {

        // 1 获取job信息
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);
        // 2 设置加载jar包路径
        job.setJarByClass(MapJoinDriver.class);
        // 3 关联mapper
        job.setMapperClass(MapJoinMapper.class);
        // 4 设置Map输出KV类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(NullWritable.class);
        // 5 设置最终输出KV类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NullWritable.class);

        // 加载缓存数据
        job.addCacheFile(new URI("hdfs://192.168.79.101:9000/test_data/cache/pd.txt"));
        // Map端Join的逻辑不需要Reduce阶段，设置reduceTask数量为0
        job.setNumReduceTasks(0);

        // 6 设置输入输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        // 7 提交
        boolean b = job.waitForCompletion(true);
        System.exit(b ? 0 : 1);
    }

}
```



#### (5) 输出结果

![](pic\22result_mapjoin.png)

### 12.etl实操

去除日志中字段个数小于等于11的日志  

需要在Map阶段对输入的数据根据规则进行过滤清洗

#### (1) bean

#### (2) mapper

```java

public class WebLogMapper extends Mapper<LongWritable, Text, Text, NullWritable> {

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        // 1 获取一行
        String line = value.toString();

        // 2 ETL
        boolean result = parseLog(line, context);

        if (!result){
            return;
        }

        // 3 写出
        context.write(value, NullWritable.get());
    }

    private boolean parseLog(String line, Context context) {
        // 切割
        // 1.206.126.5 - - [19/Sep/2013:05:41:41 +0000] "-" 400 0 "-" "-"
        String[] fields = line.split(" ");

        // 2 判断一下日志的长度是否大于11
        if (fields.length > 11){
            return true;
        }else {
            return false;
        }
    }
}
```



#### (3) reducer

#### (4) driver

```java

public class WebLogDriver {

    public static void main(String[] args) throws Exception {

        // 输入输出路径需要根据自己电脑上实际的输入输出路径设置

        // 1 获取job信息
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);

        // 2 加载jar包
        job.setJarByClass(LogDriver.class);

        // 3 关联map
        job.setMapperClass(WebLogMapper.class);

        // 4 设置最终输出类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NullWritable.class);

        // 设置reducetask个数为0
        job.setNumReduceTasks(0);

        // 5 设置输入和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 6 提交
        boolean b = job.waitForCompletion(true);
        System.exit(b ? 0 : 1);
    }

}

```



#### (5) 输出结果

![](pic\23result_etl.png)

### 13.压缩

#### (1)bean

#### (2)mapper

使用wordcount代码的mapper

#### (3)reducer

使用wordcount代码的reduce

#### (4)driver

```java

public class WordCountCompressDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        // 1 获取job
        Configuration conf = new Configuration();

        // 开启map端输出压缩
        conf.setBoolean("mapreduce.map.output.compress", true);

        // 设置map端输出压缩方式
        conf.setClass("mapreduce.map.output.compress.codec", SnappyCodec.class, CompressionCodec.class);

        Job job = Job.getInstance(conf);

        // 2 设置jar包路径
        job.setJarByClass(WordCountDriver.class);
        // 3 关联mapper和reducer
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);
        // 4 设置map输出的kv类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        // 5 设置最终输出的kV类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        // 6 设置输入路径和输出路径
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        // 设置reduce端输出压缩开启
        FileOutputFormat.setCompressOutput(job, true);
        // 设置压缩的方式
        FileOutputFormat.setOutputCompressorClass(job, BZip2Codec.class);
//	    FileOutputFormat.setOutputCompressorClass(job, GzipCodec.class);
	    FileOutputFormat.setOutputCompressorClass(job, DefaultCodec.class);
        // 7 提交job
        boolean result = job.waitForCompletion(true);
        System.exit(result ? 0 : 1);
    }
}
```

#### (5)输出结果

![](pic\24compress.png)

### 14. 最终结果

![](pic\25result_final.png)