package com.xxx.demo.map;

import com.xxx.demo.bean.FlowGlobalSortBean;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

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
