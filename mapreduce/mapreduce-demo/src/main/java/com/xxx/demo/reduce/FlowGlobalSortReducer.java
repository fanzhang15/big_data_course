package com.xxx.demo.reduce;

import com.xxx.demo.bean.FlowGlobalSortBean;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class FlowGlobalSortReducer extends Reducer<FlowGlobalSortBean, Text, Text, FlowGlobalSortBean> {

    @Override
    protected void reduce(FlowGlobalSortBean key, Iterable<Text> values, Context context) throws IOException, InterruptedException {

        for (Text value : values) {

            context.write(value,key);
        }
    }
}
