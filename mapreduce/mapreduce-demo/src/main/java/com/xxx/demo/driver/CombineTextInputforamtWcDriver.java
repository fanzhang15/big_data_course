package com.xxx.demo.driver;

import com.xxx.demo.map.CombineTextInputforamtWcMapper;
import com.xxx.demo.reduce.CombineTextInputforamtWcReducer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.CombineTextInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

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
