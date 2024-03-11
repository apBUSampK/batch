help()
{
	echo "Usage:"
	echo "run.sh [OPTIONS] [PROJ] [TARGET] [ENERGY] [NEVENTS_PER_FILE]"
	echo "[OPTIONS] is a list of options (possible listed below)"
	echo "[PROJ] and [TARGET] are projectile and target nuclei"
	echo "[ENERGY] is either sqrt(s_nn) or E_A, depending on geometry"
	echo "[NEVENTS_PER_FILE] is requested amount of events per file (per job)"
	echo "Options list:"
	echo "-h:			Display this help"
	echo "-g:			Change collision geometry to 'fixed target' (no flag is 'collider')"
	echo "-b [lb]:		Set impact parameter lower bound. Use with \"-B\" flag."
	echo "-B [ub]:		Set impact parameter upper bound. Use with \"-b\" flag."
	echo "-f [fnum]:		Change the level density function for calculating excitation energy (default is 4, consult AAMCC for further help)"
	echo "-o [output_dir]:	Set custom output directory (default is /scratch1/${USER}/AAMCC_output)"
	echo "-P [prefix]:		Set output subdirectory prefix (default: \"AAMCC_\")"
	echo "-S [suffix]:		Set output subdirectory suffix"
	echo "-u [work_dir]:		Set directory, containing makeup.sh and aamcc-build dir (default: /scratch1/${USER})"
	echo "-j [job_count]:		Set job count (default is 1)"
}

proj=
target=
energy=
nevents=
geom=1
imp_par=-1
IMP_par=
ldf=4
pref=AAMCC_
suf=
jobs=1

dir_name=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
usr_dir=/scratch1/${USER}
output_dir=${usr_dir}/AAMCC_output

while getopts ':hgb:B:f:P:S:o:u:j:' opt; do
        case "$opt" in
                h) help; exit 0 ;;
                g) geom=0 ;;
                b) imp_par=$OPTARG ;;
		B) IMP_par=$OPTARG ;;
                f) ldf=$OPTARG ;;
                P) pref=$OPTARG ;;
                S) suf=$OPTARG ;;
                j) jobs=$OPTARG ;;
		o) output_dir=$OPTARG ;;
		u) usr_dir=$OPTARG ;;
                :) echo "-$OPTARG is used with an argument! Type \"./run.sh -h\" for help!"; exit 1 ;;
                ?) ;;
                *) echo "-$OPTARG is an invalid option! Type \"./run.sh -h\" for help!"; exit 1 ;;
        esac;
done

if [[ ( $IMP_par -lt $imp_par ) || ( -n $IMP_par && $imp_par -lt 0 ) ]]; then
	echo "Error: wrong impact parameter bounds settings!"
	exit 0
fi

shift $(($OPTIND - 1))

proj=$1
target=$2
energy=$3
nevents=$4

jobRange=1-$jobs
time=3:0:0

export out_path=${output_dir}/${pref}${proj}${target}_$( [ $geom == "1" ] && echo "cld_" )${energy}${suf}

mkdir -p ${out_path}/grid_log
mkdir -p ${out_path}/log

rsync -v ${dir_name}/inputfile.template $out_path/inputfile

sed -i -- "s~proj~${proj}~g" $out_path/inputfile
sed -i -- "s~targ~${target}~g" $out_path/inputfile
sed -i -- "s~imp_par~${imp_par}~g" $out_path/inputfile
sed -i -- "s~IMP_par~${IMP_par}~g" $out_path/inputfile
sed -i -- "s~geom~${geom}~g" $out_path/inputfile
sed -i -- "s~energy~${energy}~g" $out_path/inputfile
sed -i -- "s~nevents~${nevents}~g" $out_path/inputfile
sed -i -- "s~ldf~${ldf}~g" $out_path/inputfile

export aamcc_path=${usr_dir}/aamcc-build
. ${usr_dir}/makeup.sh

exclude_nodes="ncx[182,211,112,114-117]"
sbatch --job-name=aamcc_${proj}${target}_${energy} -t $time --array=$jobRange -o ${out_path}/grid_log/%A_%a.out -e ${out_path}/grid_log/%A_%a.err --export=ALL --exclude=${exclude_nodes} ${dir_name}/run_gen.sh

squeue --name=aamcc_${proj}${target}_${energy}
