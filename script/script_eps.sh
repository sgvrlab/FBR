# NEED TO SET
DATASET_ROOT=./VOC2012
WEIGHT_ROOT=./weights
SALIENCY_ROOT=./SALImages
GPU=0,1

# Default setting
IMG_ROOT=${DATASET_ROOT}/JPEGImages
SAL_ROOT=${SALIENCY_ROOT}
BACKBONE=resnet38_eps
SESSION=resnet38_eps
BASE_WEIGHT=${WEIGHT_ROOT}/ilsvrc-cls_rna-a1_cls1000_ep-0001.params


# train classification network with EPS
CUDA_VISIBLE_DEVICES=${GPU} python3 train.py \
  --session ${SESSION} \
  --network network.${BACKBONE} \
  --data_root ${IMG_ROOT} \
  --saliency_root ${SAL_ROOT} \
  --weights ${BASE_WEIGHT} \
  --crop_size 448 \
  --tau 0.4 \
  --max_iters 10000 \
  --iter_size 2 \
  --batch_size 8


# 2. inference CAM
DATA=train # train / train_aug
TRAINED_WEIGHT=train_log/${SESSION}/checkpoint_cls.pth

CUDA_VISIBLE_DEVICES=${GPU} python3 infer.py \
    --infer_list data/voc12/${DATA}_id.txt \
    --img_root ${IMG_ROOT} \
    --network network.${BACKBONE} \
    --weights ${TRAINED_WEIGHT} \
    --thr 0.20 \
    --n_gpus 2 \
    --n_processes_per_gpu 1 1 \
    --cam_png train_log/${SESSION}/result/cam_png

# 3. evaluate CAM
GT_ROOT=${DATASET_ROOT}/SegmentationClassAug/

CUDA_VISIBLE_DEVICES=${GPU} python3 evaluate_png.py \
    --datalist data/voc12/${DATA}.txt \
    --gt_dir ${GT_ROOT} \
    --save_path train_log/${SESSION}/result/${DATA}.txt \
    --pred_dir train_log/${SESSION}/result/cam_png