import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class MultithreadedWorkflow {
    public static void main(String[] args) {
        // create fixed 4-thread pool
        ExecutorService executor = Executors.newFixedThreadPool(4);

        CountDownLatch latch1 = new CountDownLatch(2);    // latch 1 -> tasks A & B
        CountDownLatch latch2 = new CountDownLatch(2);    // latch 2 -> tasks C & D

        // run A & B in parallel
        executor.submit(() -> {
            processA();
            latch1.countDown();
        });
        executor.submit(() -> {
            processB();
            latch1.countDown();
        });

        try {
            // wait for A & B to finish before starting C & D
            latch1.await(); 
            System.out.println("Tasks A & B completed");

            System.out.println("Starting Tasks C & D");

            // run C & D in parallel
            executor.submit(() -> {
                processC();
                latch2.countDown();
            });
            executor.submit(() -> {
                processD();
                latch2.countDown();
            });

            // wait for C & D to finish before starting F
            latch2.await(); 
            System.out.println("Tasks C & D completed");

            System.out.println("Starting Task F");

            // run F
            executor.submit(() -> processF());

        } catch (InterruptedException e) {
            System.err.println("Error in main thread: " + e.getMessage());
        } finally {
            executor.shutdown();

            try {
                executor.awaitTermination(1, TimeUnit.MINUTES);
            } catch (InterruptedException e) {
                executor.shutdownNow();
            }

            System.out.println("Workflow completed");
        }
    }

    // 6 simulated tasks A-F
    private static void processA() {
        System.out.println("Processing Task A");
        sleep(2500);
        System.out.println("Task A completed");
    }

    private static void processB() {
        System.out.println("Processing Task B");
        sleep(2000);
        System.out.println("Task B completed");
    }

    private static void processC() {
        System.out.println("Processing Task C");
        sleep(1500);
        System.out.println("Task C completed");
    }

    private static void processD() {
        System.out.println("Processing Task D");
        sleep(1000);
        System.out.println("Task D completed");
    }

    // Task E is not used in this problem
    // private static void processE() {
    //     System.out.println("Processing Task E");
    //     sleep(500);
    //     System.out.println("Task E completed");
    // }

    private static void processF() {
        System.out.println("Processing Task F");
        sleep(2500);
        System.out.println("Task F completed");
    }

    private static void sleep(int milliseconds) {
        try {
            Thread.sleep(milliseconds);
        } catch (InterruptedException e) {
            System.err.println("Thread interrupted: " + e.getMessage());
        }
    }
}