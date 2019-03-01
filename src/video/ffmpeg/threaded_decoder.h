/*!
 *  Copyright (c) 2019 by Contributors
 * \file threaded_decoder.h
 * \brief FFmpeg threaded decoder definition
 */

#ifndef DECORD_VIDEO_FFMPEG_THREADED_DECODER_H_
#define DECORD_VIDEO_FFMPEG_THREADED_DECODER_H_

#include "filter_graph.h"

#include <thread>

#include <dmlc/concurrency.h>

namespace decord {
namespace ffmpeg {

class FFMPEGThreadedDecoder {
    using PacketQueue = dmlc::ConcurrentBlockingQueue<AVPacket*>;
    using PacketQueuePtr = std::unique_ptr<PacketQueue>;
    using FrameQueue = dmlc::ConcurrentBlockingQueue<AVFrame*>;
    using FrameQueuePtr = std::unique_ptr<FrameQueue>;
    using FFMPEGFilterGraphPtr = std::shared_ptr<FFMPEGFilterGraph>;

    public:
        FFMPEGThreadedDecoder();
        void SetCodecContext(AVCodecContext *dec_ctx);
        void Start();
        void Stop();
        void Clear();
        void Push(AVPacket* pkt);
        bool Pop(AVFrame **frame);
        ~FFMPEGThreadedDecoder();
    private:
        void WorkerThread();
        // void FetcherThread(std::condition_variable& cv, FrameQueuePtr frame_queue);
        PacketQueuePtr pkt_queue_;
        FrameQueuePtr frame_queue_;
        std::atomic<int> frame_count_;
        std::thread t_;
        // std::thread fetcher_;
        // std::condition_variable cv_;
        std::atomic<bool> run_;
        FFMPEGFilterGraphPtr filter_graph_;
        AVCodecContext *dec_ctx_;

    DISALLOW_COPY_AND_ASSIGN(FFMPEGThreadedDecoder);
};

}  // namespace ffmpeg
}  // namespace decord

#endif  // DECORD_VIDEO_FFMPEG_THREADED_DECODER_H_