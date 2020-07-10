//
//  ViewController.swift
//  swift_ multi_threading
//
//  Created by AlbertYuan on 2020/7/10.
//  Copyright © 2020 AlbertYuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //syncSession()

        //asyncSession()

        //DispatchQoSSession()

        //seriarQueue()

        //concurrnetQueue()

        //afterDelaySession()

        //DispatchGroupSession()

        //DispatchWorkItemSession()

        //DispatchWorkItemSession2()

        //DispatchWorkItemSession22()

        //DispatchSemaphoreSeeeion()

        DispatchWorkItemFlagsBarrier()


    }



    //sync:队列同步操作时，当程序在进行队列任务时，主线程的操作并不会被执行，这是由于当程序在执行同步操作时，会阻塞线程，所以需要等待队列任务执行完毕，程序才可以继续执行。
    func syncSession() -> () {
        let queue = DispatchQueue(label: "com.albertyuan1.www")
        queue.sync {
            for i in 0 ... 10{
                print("\(i)")
            }
        }

        for i in 20 ... 25{
            print("\(i)")
        }
    }


    //async:队列异步操作时，当程序在执行队列任务时，不必等待队列任务开始执行，便可执行主线程的操作。与同步执行相比，异步队列并不会阻塞主线程，当主线程空闲时，便可执行别的任务。
    func asyncSession() -> () {
        let queue = DispatchQueue(label: "com.albertyuan2.www")
        queue.async {
            for i in 0 ... 10{
                print("\(i)")
            }
        }

        for i in 20 ... 25{
            print("\(i)")
        }
    }


    //DispatchQoS 优先级    交替输出，CPU会把更多的资源优先分配给优先级高的队列，等到CPU空闲之后才会分配资源给优先级低的队列。default > utility
    func DispatchQoSSession() -> Void {

        let queue1 = DispatchQueue(label: "com.ffib.blog.queue1", qos: .default)
        let queue2 = DispatchQueue(label: "com.ffib.blog.queue2", qos: .utility)

        queue1.async {
            for i in 5..<10 {
                print(i)
            }
        }

        queue2.async {
            for i in 0..<5 {
                print(i)
            }
        }

    }


    //串行队列：队列执行结果，是按任务添加的顺序，依次执行。  initiallyInactive.queue
    func seriarQueue() -> () {
        let queue = DispatchQueue(label: "com.ffib.blog.initiallyInactive.queue", qos: .utility)

        queue.async {
            for i in 0..<5 {
                print(i)
            }
        }

        queue.async {
            for i in 5..<10 {
                print(i)
            }
        }

        queue.async {
            for i in 10..<15 {
                print(i)
            }
        }
    }


    //并行队列
    func concurrnetQueue() -> () {
//        let queue = DispatchQueue(label: "com.ffib.blog.concurrent.queue", qos: .utility,
//                                  attributes: .initiallyInactive) //只是把自动执行变为手动触发，执行结果没变，添加这一属性带来了，更多的灵活性，可以自由的决定执行的时机。

//        let queue = DispatchQueue(label: "com.ffib.blog.concurrent.queue", qos: .utility, attributes:[.concurrent, .initiallyInactive])

        let queue = DispatchQueue(label: "com.ffib.blog.concurrent.queue", qos: .utility, attributes:[.concurrent])

        queue.async {
            for i in 0..<5 {
                print(i)
            }
        }
        queue.async {
            for i in 5..<10 {
                print(i)
            }
        }
        queue.async {
            for i in 10..<15 {
                print(i)
            }
        }

        //需要调用activate，激活队列。
        queue.activate()

    }


    //延时执行 :GCD提供了任务延时执行的方法，通过对已创建的队列，调用延时任务的函数即可。其中时间以DispatchTimeInterval设置，GCD内跟时间参数有关系的参数都是通过这一枚举来设置。wallDeadline 和 deadline，当系统睡眠后,wallDeadline会继续，但是deadline会被挂起。例如：设置参数为60分钟，当系统睡眠50分钟，wallDeadline会在系统醒来之后10分钟执行，而deadline会在系统醒来之后60分钟执行。
    func afterDelaySession() {
        let queue = DispatchQueue(label: "com.ffib.blog.after.queue")

        let time = DispatchTimeInterval.seconds(5)
        print("\(NSDate.now)")

        queue.asyncAfter(wallDeadline: .now() + time) {
            print("wall dead line done \(NSDate.now)")
        }

        queue.asyncAfter(deadline: .now() + time) {
            print("dead line done \(NSDate.now)")
        }
    }



    //想等到所有的队列的任务执行完毕再进行某些操作时，可以使用DispatchGroup来完成
    func DispatchGroupSession(){
        let group = DispatchGroup()
        let queue1 = DispatchQueue(label: "com.ffib.blog.queue1", qos: .utility)
        let queue2 = DispatchQueue(label: "com.ffib.blog.queue2", qos: .utility)

        queue1.async(group: group) {
            for i in 0..<10 {
                print(i)
            }
        }

        //如果想等待某一队列先执行完毕再执行其他队列可以使用wait
        //group.wait()
        //为防止队列执行任务时出现阻塞，导致线程锁死，可以设置超时时间。
        //group.wait(timeout: 25)
        //group.wait(wallTimeout: 25)

        
        queue2.async(group: group) {
            for i in 10..<20 {
                print(i)
            }
        }

        //group内所有线程的任务执行完毕
        group.notify(queue: DispatchQueue.main) {
            print("done")

        }

    }


    //Swift3新增的api，可以通过此api设置队列执行的任务。通过DispatchWorkItem初始化闭包。
    func DispatchWorkItemSession(){
        let workItem = DispatchWorkItem {
            for i in 0..<10 {
                print(i)
            }
        }
        //调用一共分两种情况，第一种是通过调用perform()，自动响应闭包。
//        DispatchQueue.global().async {
//            workItem.perform()
//        }
        //第二种是作为参数传给async方法。
        DispatchQueue.global().async(execute: workItem)
    }


    func DispatchWorkItemSession2(){

        //DispatchWorkItem的init(qos: DispatchQoS = default, flags: DispatchWorkItemFlags = default,block: @escaping () -> Void) //初始化方法开始，DispatchWorkItem也可以设置优先级，另外还有个参数DispatchWorkItemFlags

        let queue1 = DispatchQueue(label: "com.ffib.blog.workItem1", qos: .utility)
        let queue2 = DispatchQueue(label: "com.ffib.blog.workItem2", qos: .userInitiated)

        let workItem1 = DispatchWorkItem(qos: .userInitiated) {   //可见即使设置了DispatchWorkItem仅仅只设置了优先级并不会对任务执行顺序有任何影响。
            for i in 0..<5 {
                print(i)
            }
        }
        let workItem2 = DispatchWorkItem(qos: .utility) {
            for i in 5..<10 {
                print(i)
            }
        }

        queue1.async(execute: workItem1)
        queue2.async(execute: workItem2)

    }


    func DispatchWorkItemSession22(){

        let queue1 = DispatchQueue(label: "com.ffib.blog.workItem1", qos: .utility)
        let queue2 = DispatchQueue(label: "com.ffib.blog.workItem2", qos: .userInitiated)

        let workItem1 = DispatchWorkItem(qos: .userInitiated, flags: .enforceQoS) { //设置enforceQoS，使优先级强制覆盖queue的优先级
            for i in 0..<5 {
                print(i)
            }
        }

        let workItem2 = DispatchWorkItem {
            for i in 5..<10 {
                print(i)
            }
        }

        queue1.async(execute: workItem1)
        queue2.async(execute: workItem2)

    }


    //DispatchSemaphore信号量：同步执行一个异步队列任务，可以使用信号量。wait()会使信号量减一，如果信号量大于1则会返回.success，否则返回timeout（超时），也可以设置超时时间。
    //func wait(wallTimeout: DispatchWallTime) -> DispatchTimeoutResult
    //func wait(timeout: DispatchTime) -> DispatchTimeoutResult
    func DispatchSemaphoreSeeeion(){
        //初始化信号量为1
        let semaphore = DispatchSemaphore(value: 1)

        let queue = DispatchQueue(label: "com.ffib.blog.queue", qos: .utility, attributes: .concurrent)

        let fileManager = FileManager.default
        let path = NSHomeDirectory() + "/test.txt"
        print(path)
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)

        //循环写入，预期结果为test4
        for i in 0..<5 {
            //.distantFuture代表永远
               if semaphore.wait(wallTimeout: .distantFuture) == .success {
                    queue.async {
                        do {
                            try "test\(i)".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                        }catch {
                            print(error)
                        }

                        semaphore.signal()
                    }
                }
            }
    }


    //DispatchWorkItemFlags---->barrier可以理解为隔离，还是以文件读写为例，在读取文件时，可以异步访问，但是如果突然出现了异步写入操作，我们想要达到的效果是在进行写入操作的时候，使读取操作暂停，直到写入操作结束，再继续进行读取操作，以保证读取操作获取的是文件的最新内容。
    func DispatchWorkItemFlagsBarrier(){
        let queue = DispatchQueue(label: "com.ffib.blog.queue", qos: .utility, attributes: .concurrent)

        let fileManager = FileManager.default
        let path = NSHomeDirectory() + "/test.txt"
        print(path)
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)

        let readWorkItem = DispatchWorkItem {
            do {
                let str = try String(contentsOfFile: path, encoding: .utf8)
                print(str)
            }catch {
                print(error)
            }
        }

        let writeWorkItem1 = DispatchWorkItem(flags: .barrier) { //barrier主要用于读写隔离，以保证写入的时候，不被读取
            do {
                try "test1".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                print("write--test1")
            }catch {
                print(error)
            }
        }

        let writeWorkItem = DispatchWorkItem(flags: .barrier) {
            do {
                try "done".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                print("write")
            }catch {
                print(error)
            }
        }

        queue.async(execute: writeWorkItem1)

        for _ in 0..<3 {
            queue.async(execute: readWorkItem)
        }

        queue.async(execute: writeWorkItem)

        for _ in 0..<3 {
            queue.async(execute: readWorkItem)
        }

    }



    func mainQueueAsync(){

         //主队列异步：  串行
        let queue = DispatchQueue.main
        queue.async {

        }


        //全局异步：并行
        let queuee = DispatchQueue.global()
        queuee.async {

        }
    }

}


/*
 线程与进程
 线程与进程之间的关系，拿公司举例，进程相当于部门，线程相当于部门职员。即进程内可以有一个或多个线程。


串行队列（并发）与并行队列
一个串行队列对应只有一个线程，因此同时只能执行一个操作，先追加的操作先执行。执行很多操作的时候就好像人们排队买东西一样，先来后到。一个并行队列可以有多个线程，同时可以执行多个操作。在执行多个操作的时候，执行顺序会根据操作内容和系统状态发生变化。

 同步和异步
 同步指在执行一个函数时，如果这个函数没有执行完毕，那么下一个函数便不能执行。异步指在执行一个函数时，不必等到这个函数执行完毕，便可开始执行下一个函数。


 public struct DispatchQoS : Equatable {

      public static let userInteractive: DispatchQoS //用户交互级别，需要在极快时间内完成的，例如UI的显示:
      public static let userInitiated: DispatchQoS  //用户发起，需要在很快时间内完成的，例如用户的点击事件、以及用户的手势
      public static let `default`: DispatchQoS  //系统默认的优先级，
      public static let utility: DispatchQoS   //实用级别，不需要很快完成的任务
      public static let background: DispatchQoS  //用户无法感知，比较耗时的一些操作
      public static let unspecified: DispatchQoS
 }
 主队列默认使用拥有最高优先级，即userInteractive，所以慎用这一优先级，否则极有可能会影响用户体验。
 一些不需要用户感知的操作，例如缓存等，使用utility即可

 public enum DispatchTimeInterval : Equatable {

     case seconds(Int)     //秒
     case milliseconds(Int) //毫秒
     case microseconds(Int) //微妙
     case nanoseconds(Int)  //纳秒
     case never

 }


 public struct DispatchWorkItemFlags : OptionSet, RawRepresentable {

     public static let barrier: DispatchWorkItemFlags  //barrier栅栏，多读单写操作
     public static let detached: DispatchWorkItemFlags
     public static let assignCurrentContext: DispatchWorkItemFlags


     public static let noQoS: DispatchWorkItemFlags //noQoS 没有优先级
     public static let inheritQoS: DispatchWorkItemFlags  //inheritQoS 继承Queue的优先级
     public static let enforceQoS: DispatchWorkItemFlags  //enforceQoS 覆盖Queue的优先级

 }

 */
